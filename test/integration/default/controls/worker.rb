title 'spark-worker'

control 'sw-01' do
  impact 1.0
  title 'Check spark-worker service'
  describe service("spark-worker") do
    it { should be_enabled }
    it { should be_running }
  end
end

control 'sw-02' do
  title 'Check for open ports'
  impact 1.0
  portlist = [8081]
  for p in portlist do
    describe port(p) do
      it { should be_listening }
    end
  end
end

control 'sw-03' do
  title 'Check spark logging directory'
  impact 1.0  
  describe file('/var/log/spark') do
    it { should be_directory }
    it { should be_owned_by 'spark' }
    it { should be_readable.by('owner') }
    it { should be_readable.by('group') }
    it { should be_readable.by('other') }
    it { should be_writable.by('owner') }
    it { should_not be_writable.by('other') }
  end
end

control 'sw-04' do
  title 'Check spark run directory'
  impact 1.0
  desc 'Asserts the run dir can be used by spark'
  describe file('/var/run/spark') do
    it { should be_directory }
    it { should be_owned_by 'spark' }
  end

end
