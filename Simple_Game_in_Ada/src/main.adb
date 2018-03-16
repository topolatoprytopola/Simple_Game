with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Integer_Text_IO;
use Ada.Integer_Text_IO;
with Ada.Characters.Latin_1;
with Ada.Numerics.Discrete_Random;
procedure Main is
   Counter   : Integer := 5;
   pragma Atomic (Counter);
   level:Duration :=1.0;
   points:Integer:=0;
   pragma Atomic (points);
   exitp:Integer:=1;
   pragma Atomic (exitp);
   lvl1:Integer:=1;
   pragma Atomic (lvl1);
   type Character_Display is array (Positive range <>, Positive range <>) of Character;
   Board: Character_Display(1 .. 5, 1 .. 11) :=
     (1 => ('X', ' ', ' ', ' ',' ',' ',' ',' ', 'X',' ',' '),
      2 => ('X', ' ', ' ', ' ',' ',' ',' ',' ', 'X',' ',' '),
      3 => ('X', ' ', ' ', ' ',' ',' ',' ',' ', 'X',' ',' '),
      4 => ('X', ' ', ' ', ' ',' ',' ',' ',' ', 'X',' ',' '),
      5 => ('X', ' ', ' ', ' ','A',' ',' ',' ', 'X',' ',' '));
   task lvl is
      entry Start;
   end lvl;
   task move is
      entry Start;
   end move;
   task show is
      entry Start;
   end show;
   task objectmove is
      entry Start;
   end objectmove;
   task object is
      entry Start;
   end object;
   package RandGen is
      function generate_random_number ( n: in Positive) return Integer;
   end RandGen;
   package body RandGen is

      subtype Rand_Range is Positive;
      package Rand_Int is new Ada.Numerics.Discrete_Random(Rand_Range);

      gen : Rand_Int.Generator;

      function generate_random_number ( n: in Positive) return Integer is
      begin
         return Rand_Int.Random(gen) mod n;
      end generate_random_number;

   begin
      Rand_Int.Reset(gen);
   end RandGen;
   task body object is
      G : Integer;
   begin
      accept Start;
      object_loop:
      while true loop
         for I in Integer range 2..8 loop
            G:=RandGen.generate_random_number(6);
            if G=1 then
               Board(1,I):='X';
            else
               Board(1,I):=' ';
            end if;
            if exitp=0 then
               exit object_loop;
            end if;
         end loop;
         delay level;
      end loop object_loop;
   end object;
   task body move is
      Answer : Character;
   begin
      accept Start;
      if exitp/=0 then
         move_loop:
         while true loop
            Ada.Text_IO.Get_Immediate(Answer);
            if Answer = Ada.Characters.Latin_1.LC_A then
               For_loop_left:
               for I in Integer range 3 .. 8 loop
                  if Board(5,I)='A' then
                     if Board(5,I-1)='X' then
                        exitp:=0;
                     end if;
                     Board(5,I-1):='A';
                     Board(5,I):=' ';
                     exit For_loop_left;
                  end if;
               end loop For_loop_left;
            elsif Answer = Ada.Characters.Latin_1.LC_D then
               For_loop_right:
               for I in Integer range 2 .. 7 loop
                  if Board(5,I)='A' then
                     if Board(5,I+1)='X' then
                        exitp:=0;
                     end if;
                     Board(5,I+1):='A';
                     Board(5,I):=' ';
                     exit For_loop_right;
                  end if;
               end loop For_loop_right;
            elsif Answer = Ada.Characters.Latin_1.LC_W then
               exitp:=0;
            end if;
            if exitp=0 then
               exit move_loop;
            end if;
         end loop move_loop;
      end if;
   end move;
   task body show is
   begin
      accept Start;
      if exitp/=0 then
         show_loop:
         while true loop
            Ada.Text_IO.Put(ASCII.ESC & "[2J");
            Put("Punkty:");
            Put(points);
            new_line;
            Put("Poziom:");
            Put(lvl1);
            new_line;
            for I in Integer range 2 .. 5 loop
               for J in Integer range 1.. 11 loop
                  Put(Board(I,J));
                  null;
               end loop;
               new_line;
            end loop;
            Put_Line("A,D-aby sie poruszac");
            Put_Line("W-aby wyjsc");
            if exitp=0 then
               exit show_loop;
            end if;
            delay 0.01;
         end loop show_loop;
      end if;
   end show;
   task body lvl is
   begin
      accept Start;
      if exitp/=0 then
         lvl_loop:
         while true loop
            delay 5.0;
            if level=0.2 then
               null;
            else
               level:=level - 0.2;
               lvl1:=lvl1+1;
            end if;
            if exitp=0 then
               exit lvl_loop;
            end if;
         end loop lvl_loop;
      end if;
   end lvl;
   task body objectmove is
   begin
      accept Start;
      if exitp/=0 then
         objectmove_loop:
         while true loop
            for I in reverse 2 .. 5 loop
               for J in Integer range 2.. 8 loop
                  if Board(I,J)= 'A' then
                     if Board(I-1,J)=' ' then
                        null;
                     else
                        Board(I,J):= Board(I-1,J);
                        exitp:=0;
                     end if;
                  else
                     Board(I,J):= Board(I-1,J);
                  end if;
               end loop;
            end loop;
            points:=points+1;
            if exitp=0 then
               exit objectmove_loop;
            end if;
            delay level;
         end loop objectmove_loop;
      end if;
   end objectmove;
   choose:Boolean:=true;
   Answer2 : Character;
begin
   Put_Line("Co chcesz zrobic?");
   Put_Line("S-start gry");
   Put_Line("W-wyjdz");
   while choose=true loop
      Ada.Text_IO.Get_Immediate(Answer2);
      if Answer2 = Ada.Characters.Latin_1.LC_S then
         choose:=false;
      else if Answer2 = Ada.Characters.Latin_1.LC_W then
            choose:=false;
            exitp:=0;
         end if;
      end if;
   end loop;
   move.Start;
   show.Start;
   object.Start;
   objectmove.Start;
   lvl.Start;
   end_loop:
   while true loop
      if exitp=0 then
         exit end_loop;
      end if;
   end loop end_loop;
   delay 1.0;
   if points/=0 then
      Put("Wynik koncowy:");
      Put(points);
   end if;
end Main;
