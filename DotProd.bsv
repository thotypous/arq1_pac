import BRAM::*;
import BUtils::*;
import FloatingPoint::*;

typedef 3 VectorLength;  // número de posições dos vetores contidos nas BRAMs

typedef enum {
	ReqLoad,
	ReqMult,
	Accum,
	Done
} State deriving (Eq, Bits, FShow);

typedef LBit#(VectorLength) Addr;


module mkDotProd (Empty);
	BRAM_Configure cfg = defaultValue;
	cfg.memorySize = valueOf(VectorLength);

	cfg.loadFormat = tagged Hex "a.hex";
	BRAM1Port#(Addr, Float) memA <- mkBRAM1Server(cfg);

	cfg.loadFormat = tagged Hex "b.hex";
	BRAM1Port#(Addr, Float) memB <- mkBRAM1Server(cfg);

	function req(addr) =
		BRAMRequest{
			write: False,
			responseOnWrite: False,
			address: addr,
			datain: ?
		};

	Server#(Tuple4#(Maybe#(Float), Float, Float, RoundMode), Tuple2#(Float,Exception)) mac <-
		mkFloatingPointFusedMultiplyAccumulate;

	Reg#(Bit#(32)) cycles <- mkReg(0);

	Reg#(State) state <- mkReg(ReqLoad);
	Reg#(Addr) curAddr <- mkReg(0);
	Reg#(Float) result <- mkReg(unpack(32'b0));


	rule countCycles (True);
		cycles <= cycles + 1;
	endrule


	rule reqLoad (state == ReqLoad);
		$display("Requisitando da memória o endereço %d", curAddr);
		memA.portA.request.put(req(curAddr));
		memB.portA.request.put(req(curAddr));
		curAddr <= curAddr + 1;
		state <= ReqMult;
	endrule

	rule reqMult (state == ReqMult);
		let valueA <- memA.portA.response.get;
		let valueB <- memB.portA.response.get;
		$display("Obtive da memória: ", fshow(valueA), " e ", fshow(valueB), ", multiplicando");
		mac.request.put(tuple4(tagged Valid result, valueA, valueB, defaultValue));
		state <= Accum;
	endrule

	rule accum (state == Accum);
		match {.partial, .exc} <- mac.response.get;
		$display("Valor acumulado até o momento: ", fshow(partial));
		result <= partial;
		if (curAddr == fromInteger(valueOf(VectorLength)))
			state <= Done;
		else
			state <= ReqLoad;
	endrule

	rule done (state == Done);
		$display("\nProduto interno finalizado. Resultado: ", fshow(result));
		$display("Ciclos gastos: %d", cycles);
		$finish;
	endrule

endmodule