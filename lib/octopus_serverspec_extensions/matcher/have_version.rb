RSpec::Matchers.define :have_version do |version|
  match do |file|
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

    r[1] == version
  end
end
