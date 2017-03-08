class XDKsensor

	attr_reader :temperatura, :ruido, :lat, :long, :alt, :datatemp

	def initialize()
	end

	def geradorall()
		@temperatura = Random.rand(0..100)
		@long = Random.rand(0..100)
		@ruido = Random.rand(0..100)
		@lat = Random.rand(0..100)
		@alt = Random.rand(0..100)
	end

	def getdados(){
		geradorall();
		return "->"@temperatura+@ruido+@lat+@long+@alt+Time.now;
	}




