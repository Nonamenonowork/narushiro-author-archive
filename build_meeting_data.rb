require 'json'

root = File.expand_path('../evidence_meetings', __dir__)
documents_root = File.expand_path('../in_story_documents', __dir__)
output = File.expand_path('meeting-data.js', __dir__)

records = Dir.glob(File.join(root, '*')).select { |path| File.directory?(path) }.sort.map do |dir|
  files = {}
  Dir.glob(File.join(dir, '*.md')).sort.each do |path|
    files[File.basename(path, '.md')] = File.read(path, encoding: 'UTF-8')
  end
  profile = files['evidence_profile'].to_s
  title = profile.lines.find { |line| line.start_with?('# ') }&.sub(/^#\s*/, '')&.strip
  title ||= File.basename(dir)
  prefix = File.basename(dir)[0, 2]
  document_path = Dir.glob(File.join(documents_root, "#{prefix}_*.md")).first
  {
    id: File.basename(dir),
    title: title.sub(/設定仕様|資料仕様|最終仕様|エビデンス・プロファイル|プロファイル/, '').strip,
    profile: profile,
    document: document_path ? File.read(document_path, encoding: 'UTF-8') : '',
    meetings: (1..3).map do |number|
      {
        number: number,
        transcript: files["meeting_#{number}_transcript"].to_s,
        minutes: files["meeting_#{number}_minutes"].to_s
      }
    end
  }
end

File.write(output, "window.meetingData = #{JSON.generate(records)};\n", mode: 'w', encoding: 'UTF-8')
puts "generated #{records.length} evidence records -> #{output}"
