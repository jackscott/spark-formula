control 'pyspark' do
  
describe file('/opt/spark/bin/pyspark') do
  it { should be_file }
  it { should be_owned_by "spark"}
end

describe file('/opt/spark/bin/pyspark.cmd') do
  it { should be_file }
  it { should be_owned_by 'spark'}
end

end
