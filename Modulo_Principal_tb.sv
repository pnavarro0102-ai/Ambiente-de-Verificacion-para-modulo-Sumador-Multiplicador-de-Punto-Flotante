////////////////////////////////////////////////////////////////////
//
//  Modulo_Principal_tb.v
//
//  Este modulo sirve como modulo testbench del sumador y multiplicador.
//                
//  Pablo Navarro y Vladimir Gonzales
//
////////////////////////////////////////////////////////////////////

module Modulo_Principal_tb;

  
  bit CLK = 0;
  always  #5 CLK = ~CLK;               

  bit RST = 1;
  bit ENA = 0;

  bit [31:0] A, B;
  bit SEL_OP;          // 0 = ADD, 1 = MUL

  wire [31:0] OUT;
  wire [1:0]  EXC;

  Modulo_Principal DUT (CLK, RST, ENA, A, B, SEL_OP, OUT, EXC);
  
//COVERGROUPS
  
  covergroup cg_main @(posedge CLK iff ENA);

      // operación solicitada 
      cp_op : coverpoint SEL_OP {
         bins ADD = {0};
         bins MUL = {1};
      }

      //  excepción de la DUT
      cp_exc : coverpoint EXC {
         bins NONE        = {2'b00};
         bins SUBNORMAL   = {2'b01};
         bins INF_NAN     = {2'b10};
         bins RESERVED    = {2'b11};
      }

      // signos de los operandos
      cp_signA : coverpoint A[31] { bins POS = {0}; bins NEG = {1}; }
      cp_signB : coverpoint B[31] { bins POS = {0}; bins NEG = {1}; }

      // categorías de exponente A
      cp_expA : coverpoint A[30:23] {
         bins ZERO       = {8'h00};
         bins SUBNORMAL  = {[8'h01 : 8'h7F]};
         bins NORMAL     = {[8'h80 : 8'hFE]};
         bins INF_NAN    = {8'hFF};
      }

      // categorías de exponente B 
      cp_expB : coverpoint B[30:23] {
         bins ZERO       = {8'h00};
         bins SUBNORMAL  = {[8'h01 : 8'h7F]};
         bins NORMAL     = {[8'h80 : 8'hFE]};
         bins INF_NAN    = {8'hFF};
      }

      // cruces útiles 
      cross_op_exc      : cross cp_op,  cp_exc;
      cross_op_exp      : cross cp_op,  cp_expA, cp_expB;
      cross_signs       : cross cp_signA, cp_signB;
      cross_op_sign_exp : cross cp_op, cp_signA, cp_signB, cp_expA, cp_expB;

  endgroup

  cg_main cov_inst = new();   
  
  task automatic print_cov_detail (cg_main cg);
     $display("\n----------- Cobertura detallada (cg_main) ------------");
     $display("  cp_op            = %0.2f %%", cg.cp_op.get_coverage());
     $display("  cp_exc           = %0.2f %%", cg.cp_exc.get_coverage());
     $display("  cp_signA         = %0.2f %%", cg.cp_signA.get_coverage());
     $display("  cp_signB         = %0.2f %%", cg.cp_signB.get_coverage());
     $display("  cp_expA          = %0.2f %%", cg.cp_expA.get_coverage());
     $display("  cp_expB          = %0.2f %%", cg.cp_expB.get_coverage());
     $display("  cross_op_exc     = %0.2f %%", cg.cross_op_exc.get_coverage());
     $display("  cross_op_exp     = %0.2f %%", cg.cross_op_exp.get_coverage());
     $display("  cross_signs      = %0.2f %%", cg.cross_signs.get_coverage());
     $display("  cross_op_sign_exp= %0.2f %%", cg.cross_op_sign_exp.get_coverage());
     $display("-------------------------------------------------------\n");
  endtask

  function automatic bit [31:0] rand_fp32 ();
      bit [31:0] t;
      do begin
         t = $urandom;
      end while (t[30:23] == 8'h00 || t[30:23] == 8'hFF); // evita 0, denorm, Inf/NaN
      return t;
  endfunction


  function automatic bit diff_le_1lsb (bit [31:0] a, b);
      int unsigned ia = a, ib = b;
      diff_le_1lsb  = (ia > ib) ? ((ia-ib) <= 1) : ((ib-ia) <= 1);
  endfunction
  
  
  function automatic bit diff_le_ulps (bit [31:0] a, b, int unsigned tol);
    int unsigned ia = a, ib = b;
    diff_le_ulps   = (ia > ib) ? ((ia-ib) <= tol) : ((ib-ia) <= tol);
  endfunction
  
  function automatic int unsigned exp_delta (bit [31:0] a, b);
    return (a[30:23] > b[30:23]) ? (a[30:23]-b[30:23]) : (b[30:23]-a[30:23]);
  endfunction
  
  function automatic bit is_subnormal (bit [31:0] f);
    return (f[30:23] == 8'h00) && (f[22:0] != 0);
  endfunction


  initial begin
      $dumpfile("Wavetb.vcd");
      $dumpvars(0, Modulo_Principal_tb);
  end

  
  initial begin
      repeat (3) 
      @(posedge CLK);
      RST = 0;      
      ENA = 1;
  end
  
  int unsigned N = 1000;                // nº de transacciones
  int unsigned pass_cnt = 0, fail_cnt = 0;

//TESTER-SCOREBOARD
  
  initial begin : tester
      shortreal  a_sr, b_sr, res_sr;
      bit [31:0] ref_bits;
      int unsigned dE, tol;

      repeat (N) begin
         
          A       = rand_fp32();
          B       = rand_fp32();
          SEL_OP  = $urandom_range(0,1);

          repeat (3) 
          @(posedge CLK);
          #1;
      
          a_sr     = $bitstoshortreal(A);
          b_sr     = $bitstoshortreal(B);
          res_sr   = SEL_OP ? a_sr * b_sr
                            : a_sr + b_sr;
          ref_bits = $shortrealtobits(res_sr);

          
          dE  = exp_delta(A, B);
        
          if (SEL_OP && is_subnormal(ref_bits)) begin
                ref_bits = {ref_bits[31], 31'd0};  
          end

          if (SEL_OP == 0) begin               
              if      (dE > 24) tol = '1;      
              else if (dE > 0)  tol = 32'h01000000; 
              else              tol = 1;       
          end
          else begin                           
              tol = 1;                         
          end
        
         if ( (OUT === ref_bits) || diff_le_ulps(OUT, ref_bits, tol) ) begin
              pass_cnt++;
              $display("PASS (%s)  A=0x%08h  B=0x%08h  → 0x%08h",
               SEL_OP ? "MUL" : "ADD", A, B, OUT);
          end else begin
              fail_cnt++;
              $error("FAIL (%s) A=0x%08h B=0x%08h → DUT 0x%08h  REF 0x%08h",
              SEL_OP ? "MUL" : "ADD", A, B, OUT, ref_bits);
          end

          @(posedge CLK);
        
      end

      $display("========= RESUMEN =========");
      $display("Total: %0d  |  OK: %0d  |  FAIL: %0d", N, pass_cnt, fail_cnt);
    
      print_cov_detail(cov_inst); //impirme la covertura

      $finish;
  end
  


endmodule

////////////////////////////////////////////////////////////////////
