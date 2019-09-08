all: dotprod a.hex b.hex

a.hex: gentestvecs.py
	./gentestvecs.py

b.hex: gentestvecs.py
	./gentestvecs.py

dotprod: DotProd.bsv
	bsc -u -verilog -aggressive-conditions -g mkDotProd DotProd.bsv
	bsc -verilog -e mkDotProd -o dotprod

test: dotprod a.hex b.hex
	./dotprod | ./convfloats.py
