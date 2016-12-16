require "spec_helper"

describe NpmPackage do

  let(:runner) { double ("runner")}

  it "finds package if version not supplied" do
    package = NpmPackage.new("gulp")
    package.instance_variable_set("@runner", runner)
    result = instance_double("Runner", :stdout => "/usr/local/lib\n└── gulp@3.9.1 \n")

    expect(runner).to receive(:run_command).with("npm list -g gulp").and_return(result)

    expect(package.installed?(nil, nil)).to be true
  end

  it "checks version if supplied" do
    package = NpmPackage.new("gulp")
    package.instance_variable_set("@runner", runner)
    result = instance_double("Runner", :stdout => "/usr/local/lib\n└── gulp@3.9.1 \n")

    expect(runner).to receive(:run_command).twice.with("npm list -g gulp").and_return(result)

    expect(package.installed?(nil, "3.9.1")).to be true
    expect(package.installed?(nil, "3.9.0")).to be false
  end

  it "doesn't find non installed package" do
    package = NpmPackage.new("not-installed-package")
    package.instance_variable_set("@runner", runner)
    result = instance_double("Runner", :stdout => "/usr/local/lib\n└── (empty)\n")

    expect(runner).to receive(:run_command).twice.with("npm list -g not-installed-package").and_return(result)

    expect(package.installed?(nil, nil)).to be false
    expect(package.installed?(nil, "1.5")).to be false
  end

end
