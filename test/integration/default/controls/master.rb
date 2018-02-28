title 'master'

control 'spark-master-service' do
  impact 1.0
  desc 'Server: Assert spark-master is enabled and running'
  describe service("spark-master") do
    it { should be_enabled }
    it { should be_running }
  end
end

control 'spark-master-ports' do
  impact 1.0
  desc  'Server: Checks for UI and Admin ports to be open.'
  
  portlist = [8080,12345]
  for p in portlist do
    describe port(p) do
      it { should be_listening }
    end
  end

  # we override spark:lookup:master_port in a grain, assert the default port is not being listened to
  describe port(7707) do
    it { should_not be_listening }
  end
  
end

