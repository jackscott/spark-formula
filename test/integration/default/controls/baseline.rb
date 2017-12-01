

control 'spark-baseline' do
  impact 1.0


  describe file('/etc/profile.d/spark.sh') do
    it { should be_file }
    it { should be_owned_by 'root' }
  end

  
  describe file('/tmp/spark-2.2.0-bin-hadoop2.7.tgz') do
    it { should be_file }
    it { should be_owned_by 'root' }
  end

  
  describe file('/opt/spark-2.2.0-bin-hadoop2.7') do
    it { should be_directory }
    it { should be_owned_by "spark"}
  end

  describe file('/opt/spark') do
    it { should be_directory }
    it { should be_symlink } 
    it { should be_owned_by 'spark'}
  end


  describe file('/opt/spark/bin/pyspark') do
    it { should be_file }
    it { should be_owned_by 'spark' }
    it { should be_executable }
  end

end

control 'spark-defaults' do
  describe file('/etc/spark/spark-env.sh') do
    it { should be_file }
    it { should be_owned_by 'spark' }
  end
  
  describe file('/etc/spark/log4j.properties') do
    it { should be_file }
    it { should be_owned_by 'spark'}
    it { should be_grouped_into 'spark'}
  end
  
  describe file('/etc/spark/spark-defaults.conf') do
    it { should be_file }
    it { should be_owned_by 'spark' }
  end

  describe file('/etc/spark/spark-env.sh') do
    it { should be_file }
    it { should be_owned_by 'spark' }
  end
  
end
