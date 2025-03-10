library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library lpm;
use lpm.lpm_components.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity FFT_module is
	generic(
		dw:integer:=9);
	port(
		clk:in std_logic;
		load_enable:in std_logic;
		load_count:in std_logic_vector(4 downto 0);
		indata:in std_logic_vector(2*dw-1 downto 0);
		unload_enable:in std_logic;
		unload_count:in std_logic_vector(4 downto 0);
		done:out std_logic;
		unload_valid:out std_logic;
		outdata:out std_logic_vector(2*dw-1 downto 0));
end FFT_module;
	
architecture a of FFT_module is
	signal unload_enable1,unload_enable2:std_logic;
	signal load_enable1,start,LAw,LBw,Lw,RAw,Rw:std_logic;
	signal LA_a,LB_a,RA_a,RB_a:std_logic_vector(4 downto 0);
	signal LAa,LBa,RAa,RBa:std_logic_vector(4 downto 0);
	signal LA_d,LB_d,RA_d,RB_d:std_logic_vector(2*dw-1 downto 0);
	signal LAd,LBd,RAd,RBd:std_logic_vector(2*dw-1 downto 0);
	signal pass,pa:std_logic_vector(2 downto 0);
	signal cnt,ct:std_logic_vector(4 downto 0);
	signal state,pass_end,do:std_logic;
	signal Waddr_a,Waddr_b,Waddr:std_logic_vector(3 downto 0);
	signal wmax:integer range 0 to 15;
	signal xa,xb,ya,yb:std_logic_vector(2*dw-1 downto 0);
	signal xaI,xaQ,xbI,xbQ:std_logic_vector(dw downto 0);
	signal sum,dif:std_logic_vector(2*dw+1 downto 0);
	signal a,b,c,d:std_logic_vector(dw-1 downto 0);
	signal ac,bd,ad,bc:std_logic_vector(2*dw-1 downto 0);
	signal LAq,LBq,RAq,RBq,Wq:std_logic_vector(2*dw-1 downto 0);
begin
	process(clk)
	begin
		if(clk'event and clk='1')then
			if(load_enable='1')then
				LAa<=Load_count;
				LAd<=indata;
				LAw<='1';
				LBw<='0';
				RAw<='0';
			elsif(unload_enable='1')then
				RAa(4)<=unload_count(0);
				RAa(3)<=unload_count(1);
				RAa(2)<=unload_count(2);
				RAa(1)<=unload_count(3);
				RAa(0)<=unload_count(4);
				LAw<='0';
				LBw<='0';
				RAw<='0';
			else
				LAa<=LA_a;
				LAd<=LA_d;
				LAw<=Lw;
				LBa<=LB_a;
				LBd<=LB_d;
				LBw<=Lw;
				RAa<=RA_a;
				RAd<=RA_d;
				RAw<=Rw;
				RBa<=RB_a;
				RBd<=RB_d;
			end if;
		end if;
	end process;
			
	process(clk)
	begin
		if(clk'event and clk='1')then
			unload_enable1<=unload_enable;
			unload_enable2<=unload_enable1;
			unload_valid<=unload_enable2;
		end if;
	end process;
						
	process(clk)
	begin
		if(clk'event and clk='1')then
			if(unload_enable2='1')then
				outdata<=RAq;
			end if;
		end if;
	end process;
						
	process(clk)
	begin
		if(clk'event and clk='1')then
			load_enable1<=load_enable;
		end if;
	end process;
					
	process(clk)
	begin
		if(clk'event and clk='1')then
			if(load_enable='0' and load_enable1='1')then
				start<='1';
			else
				start<='0';
			end if;
		end if;
	end process;
						
	process(clk)
	begin
		if(clk'event and clk='1')then
			if(start='1')then
				state<='1';
			elsif(do='1')then
				state<='0';
			end if;
		end if;
	end process;
						
	process(clk)
	begin
		if(clk'event and clk='1')then
			if(start='1')then
				pass<="000";
			elsif(pass_end='1')then
				pass<=pass+1;
			end if;
		end if;
	end process;
	
	process(clk)
	begin
		if(clk'event and clk='1')then
			if(start='1' or pass_end='1')then
				cnt<="00000";
			elsif(state='1')then
				cnt<=cnt+1;
			end if;
		end if;
	end process;
		
	process(clk)
	begin
		if(clk'event and clk='1')then
			if(state='1')then
				if(pass(0)='0')then -- L->R
					LA_a(4)<='0'; LA_a(3 downto 0)<=cnt(3 downto 0);
					LB_a(4)<='1'; LB_a(3 downto 0)<=cnt(3 downto 0);
					RA_a(4 downto 1)<=cnt(3 downto 0)-7; RA_a(0)<='0';
					RB_a(4 downto 1)<=cnt(3 downto 0)-7; RB_a(0)<='1';
				else -- L<-R
					RA_a(4)<='0'; RA_a(3 downto 0)<=cnt(3 downto 0);
					RB_a(4)<='1'; RB_a(3 downto 0)<=cnt(3 downto 0);
					LA_a(4 downto 1)<=cnt(3 downto 0)-7; LA_a(0)<='0';
					LB_a(4 downto 1)<=cnt(3 downto 0)-7; LB_a(0)<='1';
				end if;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if(clk'event and clk='1')then
			if(state='1')then
				if(pass(0)='0')then -- L->R
					xa<=LAq;
					xb<=LBq;
				else -- L<-R
					xa<=RAq;
					xb<=RBq;
				end if;
			end if;
		end if;
	end process;
	
	process(clk)
	begin
		if(clk'event and clk='1')then
			case pass is
			when "000"=>wmax<=0;
			when "001"=>wmax<=1;
			when "010"=>wmax<=3;
			when "011"=>wmax<=7;
			when "100"=>wmax<=15;
			when others=>null;
			end case;
		end if;
	end process;

	process(clk)
		variable wcnt:integer range 0 to 15;
	begin
		if(clk'event and clk='1')then
			if(cnt="00000" or wcnt=wmax)then
				Waddr_a<=cnt(3 downto 0);
				wcnt:=0;
			else
				wcnt:=wcnt+1;
			end if;
		end if;
	end process;
	
	process(clk)
	begin
		if(clk'event and clk='1')then
			Waddr_b<=Waddr_a;
		end if;
	end process;
	
	process(clk)
	begin
		if(clk'event and clk='1')then
			if(state='1')then
				Waddr<=Waddr_b;
			end if;
		end if;
	end process;
	
	process(clk)
	begin
		if(clk'event and clk='1')then
			if(state='1')then
				if(pass(0)='0')then -- L->R
					RA_d<=ya;
					RB_d<=yb;
				else -- L<-R
					LA_d<=ya;
					LB_d<=yb;
				end if;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if(clk'event and clk='1')then
			if(state='1')then
				if(pass(0)='0')then -- L->R
					Lw<='0';
				elsif(cnt="00111")then -- L<-R 7
					Lw<='1';
				end if;
			else
				Lw<='0';
			end if;
		end if;
	end process;

	process(clk)
	begin
		if(clk'event and clk='1')then
			if(state='1')then
				if(pass(0)='1')then -- L<-R
					Rw<='0';
				elsif(cnt="00111")then -- L->R 7
					Rw<='1';
				end if;
			else
				Rw<='0';
			end if;
		end if;
	end process;

	ct<="10101"; -- 16+5=21
		
	process(clk)
	begin
		if(clk'event and clk='1')then
			if(cnt=ct)then
				pass_end<='1';
			else
				pass_end<='0';
			end if;
		end if;
	end process;
		
	pa<="100"; -- 4
		
	process(clk)
	begin
		if(clk'event and clk='1')then
			if(pass=pa)then
				do<=pass_end;
			else
				do<='0';
			end if;
		end if;
	end process;
		
	process(clk)
	begin
		if(clk'event and clk='1')then
			done<=do;
		end if;
	end process;
		
	process(clk)
	begin
		if(clk'event and clk='1')then
			xaI<=xa(2*dw-1)&xa(2*dw-1 downto dw);
			xaQ<=xa(dw-1)&xa(dw-1 downto 0);
			xbI<=xb(2*dw-1)&xb(2*dw-1 downto dw);
			xbQ<=xb(dw-1)&xb(dw-1 downto 0);
		end if;
	end process;
		
	process(clk)
	begin
		if(clk'event and clk='1')then
			sum(2*dw+1 downto dw+1)<=xaI+xbI;
			sum(dw downto 0)<=xaQ+xbQ;
		end if;
	end process;
		
	process(clk)
	begin
		if(clk'event and clk='1')then
			ya(2*dw-1 downto dw)<=sum(2*dw+1 downto dw+2);
			ya(dw-1 downto 0)<=sum(dw downto 1);
		end if;
	end process;
		
	process(clk)
	begin
		if(clk'event and clk='1')then
			dif(2*dw+1 downto dw+1)<=(xa(2*dw-1)&xa(2*dw-1 downto dw))-(xb(2*dw-1)&xb(2*dw-1 downto dw));
			dif(dw downto 0)<=(xa(dw-1)&xa(dw-1 downto 0))-(xb(dw-1)&xb(dw-1 downto 0));
		end if;
	end process;
		
	a<=dif(2*dw+1 downto dw+2);
	b<=dif(dw downto 1);
	c<=Wq(2*dw-1 downto dw);
	d<=Wq(dw-1 downto 0);
		
	r1:LPM_MULT generic map(LPM_PIPELINE=>1, LPM_REPRESENTATION=>"SIGNED", LPM_WIDTHA=>dw, LPM_WIDTHB=>dw, LPM_WIDTHP=>2*dw)
				port map(dataa=>a, datab=>c, clock=>clk, result=>ac);
	r2:LPM_MULT generic map(LPM_PIPELINE=>1, LPM_REPRESENTATION=>"SIGNED", LPM_WIDTHA=>dw, LPM_WIDTHB=>dw, LPM_WIDTHP=>2*dw)
				port map(dataa=>b, datab=>d, clock=>clk, result=>bd);
	r3:LPM_MULT generic map(LPM_PIPELINE=>1, LPM_REPRESENTATION=>"SIGNED", LPM_WIDTHA=>dw, LPM_WIDTHB=>dw, LPM_WIDTHP=>2*dw)
				port map(dataa=>a, datab=>d, clock=>clk, result=>ad);
	r4:LPM_MULT generic map(LPM_PIPELINE=>1, LPM_REPRESENTATION=>"SIGNED", LPM_WIDTHA=>dw, LPM_WIDTHB=>dw, LPM_WIDTHP=>2*dw)
				port map(dataa=>b, datab=>c, clock=>clk, result=>bc);
						
	process(clk)
	begin
		if(clk'event and clk='1')then
			yb(2*dw-1 downto dw)<=ac(2*dw-2 downto dw-1)-bd(2*dw-2 downto dw-1);
			yb(dw-1 downto 0)<=ad(2*dw-2 downto dw-1)+bc(2*dw-2 downto dw-1);
		end if;
	end process;
		
	mL:ALTSYNCRAM generic map(OPERATION_MODE=>"BIDIR_DUAL_PORT", OUTDATA_REG_A=>"UNREGISTERED", OUTDATA_REG_B=>"UNREGISTERED", WIDTH_A=>2*dw, WIDTH_B=>2*dw, WIDTHAD_A=>5, WIDTHAD_B=>5)
				  port map(clock0=>clk, clock1=>clk, address_a => LAa, data_a=>LAd, wren_a=>LAw, address_b => LBa, data_b=>LBd, wren_b=>LBw, q_a=>LAq, q_b=>LBq);
	mR:ALTSYNCRAM generic map(OPERATION_MODE=>"BIDIR_DUAL_PORT", OUTDATA_REG_A=>"UNREGISTERED", OUTDATA_REG_B=>"UNREGISTERED", WIDTH_A=>2*dw, WIDTH_B=>2*dw, WIDTHAD_A=>5, WIDTHAD_B=>5)
				  port map(clock0=>clk, clock1=>clk, address_a => RAa, data_a=>RAd, wren_a=>RAw, address_b => RBa, data_b=>RBd, wren_b=>RAw, q_a=>RAq, q_b=>RBq);
	mW:ALTSYNCRAM generic map(OPERATION_MODE=>"ROM", OUTDATA_REG_A=>"CLOCK0", WIDTH_A=>2*dw, WIDTHAD_A=>4, INIT_FILE=>"W32.mif")
				  port map(clock0=>clk, address_a=>Waddr,q_a=>Wq);
end a;