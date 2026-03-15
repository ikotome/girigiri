class UrlAnalyzer
  attr_reader :error_message

  SYSTEM_PROMPT = <<~PROMPT
    以下のページテキストからイベント・募集情報を抽出してください。
    JSON形式のみで返してください。他の文字は一切含めないでください。

    {
      "title": "イベント名",
      "category": "intern/hackathon/event/personalのいずれか",
      "deadline_at": "YYYY-MM-DD形式、不明な場合はnull",
      "event_at": "YYYY-MM-DD形式、不明な場合はnull",
      "organizer": "主催者名、不明な場合はnull"
    }
  PROMPT

  def initialize(url)
    @url = url
  end

  def analyze
    if ENV["OPENAI_API_KEY"].blank?
      @error_message = "OpenAI APIキーが設定されていません"
      return nil
    end

    html = fetch_page
    return nil unless html

    text = extract_text(html)
    if text.blank?
      @error_message = "ページ本文を抽出できませんでした"
      return nil
    end

    date_hints = extract_date_hints(text)
    result = call_openai(text, date_hints)
    if result&.values&.all?(&:nil?)
      result = call_openai(text, {}, include_hints: false)
    end
    return nil unless result

    result["deadline_at"] ||= date_hints[:deadline_at]
    result["event_at"] ||= date_hints[:event_at]
    result
  end

  private

  def fetch_page
    response = HTTParty.get(@url, timeout: 10, headers: {
      "User-Agent" => "Mozilla/5.0"
    })
    return response.body if response.success?

    @error_message = "URL先のページを取得できませんでした"
    nil
  rescue StandardError => e
    @error_message = "URL取得エラー: #{e.message}"
    nil
  end

  def extract_text(html)
    doc = Nokogiri::HTML(html)
    doc.search("script, style").remove
    full_text = doc.text.gsub(/\s+/, " ").strip
    focus_snippets = full_text.scan(/.{0,120}(?:締切|応募締切|エントリー締切|申込締切|受付締切|開催日).{0,120}/).uniq.join(" ")

    [full_text.truncate(2500), focus_snippets].join(" ").squish.truncate(5000)
  end

  def extract_date_hints(text)
    date_pattern = /[0-9０-９]{4}(?:[\/.]|年)[0-9０-９]{1,2}(?:[\/.]|月)[0-9０-９]{1,2}日?/
    deadline_fragment = text[/(?:締切|応募締切|エントリー締切|申込締切|受付締切).{0,40}/]
    deadline_match = deadline_fragment&.match(date_pattern)
    all_dates = text.scan(date_pattern).uniq

    {
      deadline_at: normalize_date(deadline_match&.[](0)),
      event_at: normalize_date(all_dates.first)
    }
  end

  def normalize_date(raw)
    return nil if raw.blank?

    normalized = raw.tr("０-９", "0-9").gsub("年", "-").gsub("月", "-").delete("日").tr("/.", "-")
    Date.parse(normalized).iso8601
  rescue ArgumentError, TypeError
    nil
  end

  def call_openai(text, date_hints, include_hints: true)
    client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
    user_content =
      if include_hints
        <<~PROMPT
          補助ヒント:
          - deadline候補: #{date_hints[:deadline_at] || "なし"}
          - event候補: #{date_hints[:event_at] || "なし"}

          ページテキスト:
          #{text}
        PROMPT
      else
        "ページテキスト：#{text}"
      end

    response = client.responses.create(
      model: "gpt-4.1-mini",
      input: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: user_content }
      ],
      text: {
        format: {
          type: "json_schema",
          name: "event_extract",
          strict: true,
          schema: {
            type: "object",
            properties: {
              title: { type: ["string", "null"] },
              category: { type: ["string", "null"], enum: ["intern", "hackathon", "event", "personal", nil] },
              deadline_at: { type: ["string", "null"] },
              event_at: { type: ["string", "null"] },
              organizer: { type: ["string", "null"] }
            },
            required: %w[title category deadline_at event_at organizer],
            additionalProperties: false
          }
        }
      }
    )

    content = Array(response.output)
      .flat_map(&:content)
      .find { |item| item.type == :output_text }
    return nil unless content

    JSON.parse(content.text.gsub(/```json|```/, "").strip)
  rescue OpenAI::Errors::RateLimitError
    @error_message = "OpenAI APIの利用上限に達しています。billing / quota を確認してください"
    nil
  rescue OpenAI::Errors::Error => e
    @error_message = "OpenAI APIエラー: #{e.message}"
    nil
  rescue JSON::ParserError
    @error_message = "AIの返答を解析できませんでした"
    nil
  rescue StandardError => e
    @error_message = "解析エラー: #{e.message}"
    nil
  end
end
