require "spec_helper"

describe ChocolateyPackage do

  let(:runner) { double ("runner")}

  it "can parse multiple lines in output (if output uses CRLF)" do
    package = ChocolateyPackage.new("netfx-4.6.2-devpack")
    package.instance_variable_set("@runner", runner)
    result = instance_double("Runner", :stdout => "dotnet4.6.2|4.6.01590.0\r\nnetfx-4.6.2-devpack|4.6.01590.0\r\n")

    expect(runner).to receive(:run_command).with("choco list -l -r netfx-4.6.2-devpack").and_return(result)

    expect(package.installed?("netfx-4.6.2-devpack", nil)).to be true
  end

  it "can parse multiple lines in output (if output uses LF)" do
    package = ChocolateyPackage.new("netfx-4.6.2-devpack")
    package.instance_variable_set("@runner", runner)
    result = instance_double("Runner", :stdout => "dotnet4.6.2|4.6.01590.0\nnetfx-4.6.2-devpack|4.6.01590.0\n")

    expect(runner).to receive(:run_command).with("choco list -l -r netfx-4.6.2-devpack").and_return(result)

    expect(package.installed?("netfx-4.6.2-devpack", nil)).to be true
  end

  it "checks version if supplied" do
    package = ChocolateyPackage.new("netfx-4.6.2-devpack")
    package.instance_variable_set("@runner", runner)
    result = instance_double("Runner", :stdout => "dotnet4.6.2|4.6.01590.0\r\nnetfx-4.6.2-devpack|4.6.01590.0\r\n")

    expect(runner).to receive(:run_command).twice.with("choco list -l -r netfx-4.6.2-devpack").and_return(result)

    expect(package.installed?("netfx-4.6.2-devpack", "4.6.01590.0")).to be true
    expect(package.installed?("netfx-4.6.2-devpack", "1.5")).to be false
  end

  it "doesn't find non installed package" do
    package = ChocolateyPackage.new("not-installed-package")
    package.instance_variable_set("@runner", runner)
    result = instance_double("Runner", :stdout => "")

    expect(runner).to receive(:run_command).twice.with("choco list -l -r not-installed-package").and_return(result)

    expect(package.installed?("not-installed-package", nil)).to be false
    expect(package.installed?("not-installed-package", "1.5")).to be false
  end

end
