require "serverspec"

set :backend, :exec

describe "Testing Apache Spark" do

  describe service("spark-master") do
    it { should be_enabled }
    it { should be_running }
  end

  portlist = [8080, 7077]
  for p in portlist do
    describe port(p) do
      it { should be_listening }
    end
  end
end

