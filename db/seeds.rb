seed_user = User.find_or_create_by!(email: "demo@example.com") do |user|
  user.name = "Demo User"
  user.provider = "seed"
  user.uid = "demo-user"
end

seed_events = [
  {
    title: "Google STEP 応募",
    category: :intern,
    organizer: "Google",
    deadline_at: Date.today,
    entry_status: :todo
  },
  {
    title: "KC3Hack エントリー",
    category: :hackathon,
    organizer: "KC3",
    deadline_at: Date.today + 2,
    entry_status: :drafting
  },
  {
    title: "RubyKaigi 奨学金",
    category: :event,
    organizer: "RubyKaigi",
    deadline_at: Date.today + 5,
    entry_status: :todo
  },
  {
    title: "夏インターン A社",
    category: :intern,
    organizer: "A社",
    deadline_at: Date.today + 14,
    entry_status: :submitted
  }
]

seed_events.each do |attrs|
  event = Event.find_or_create_by!(title: attrs[:title]) do |record|
    record.category = attrs[:category]
    record.organizer = attrs[:organizer]
  end

  event.update!(category: attrs[:category], organizer: attrs[:organizer])

  deadline = event.deadlines.first_or_initialize
  deadline.deadline_at = attrs[:deadline_at]
  deadline.save!

  entry = event.entries.find_or_initialize_by(user: seed_user)
  entry.status = attrs[:entry_status]
  entry.save!
end
