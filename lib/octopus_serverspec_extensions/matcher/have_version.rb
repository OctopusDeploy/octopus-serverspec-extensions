RSpec::Matchers.define :have_version do |version|
  match do |file|
    get_version(file) == version
  end

  failure_message do |file|
    "Expected file '#{file.name}' to have version '#{version}' but it had version '#{get_version}' instead"
  end

  failure_message_when_negated do |file|
    "Expected file '#{file.name}' to not have version '#{version}' but it did"
  end

  private
  def get_version(file)
    version_dll = Fiddle.dlopen('version.dll')

    s=''
    vsize = Fiddle::Function.new(version_dll['GetFileVersionInfoSize'],
                [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP],
                Fiddle::TYPE_LONG).call(file.name, s)

    raise 'Unable to determine the version number' unless vsize > 0

    result = ' '*vsize
    Fiddle::Function.new(version_dll['GetFileVersionInfo'],
                         [Fiddle::TYPE_VOIDP, Fiddle::TYPE_LONG,
                          Fiddle::TYPE_LONG, Fiddle::TYPE_VOIDP],
            Fiddle::TYPE_VOIDP).call(file.name, 0, vsize, result)

    rstring = result.unpack('v*').map{|s| s.chr if s<256}*''
    r = /FileVersion..(.*?)\000/.match(rstring)

    r[1]
  end
end
