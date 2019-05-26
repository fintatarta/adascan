pragma Ada_2012;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with Ada.Characters.Handling;    use Ada.Characters.Handling;

with Ada.Strings.Fixed;

package body Text_Scanners.Post_Processors is

   type Case_Processor is new Processor_Interface
   with
      record
         Action : Case_Conversion;
      end record;

   overriding
   function Process (P : Case_Processor; What : String)
                     return String
   is
   begin
      case P.Action is
         when Lower =>
            return To_Lower (What);

         when Upper =>
            return To_Upper (What);
      end case;
   end Process;

   type Trimmer is new Processor_Interface
   with
      record
         Action : Trimming_Specs;
      end record;

   overriding
   function Process (P : Trimmer; What : String) return String
   is
      use Ada;
   begin
      case P.Action is
         when Head =>
            return Strings.Fixed.Trim (What, Strings.Left);

         when Tail =>
            return Strings.Fixed.Trim (What, Strings.Right);

         when Both =>
            return Strings.Fixed.Trim (What, Strings.Both);

      end case;
   end Process;

   -----------
   -- Apply --
   -----------

   function Apply
     (P    : Post_Processor;
      What : String)
      return String
   is
      Tmp : Unbounded_String := To_Unbounded_String (What);
   begin
      for Processor of reverse P.Process_Chain loop
         Tmp := To_Unbounded_String (Processor.Process (To_String (Tmp)));
      end loop;

      return To_String (Tmp);
   end Apply;

   ---------
   -- "*" --
   ---------

   function "*" (X, Y : Post_Processor) return Post_Processor is
      Result : Post_Processor := X;
   begin
      for P of Y.Process_Chain loop
         Result.Process_Chain.Append (P);
      end loop;

      return Result;
   end "*";



   ----------------
   -- Force_Case --
   ----------------

   function Force_Case (To : Case_Conversion) return Post_Processor is
   begin
      return Create (Case_Processor'(Action => To));
   end Force_Case;

   ----------
   -- Trim --
   ----------

   function Trim (Spec : Trimming_Specs) return Post_Processor is
   begin
      return Create (Trimmer'(Action => Spec));
   end Trim;

   ------------
   -- Create --
   ------------

   function Create
     (P : Processor_Interface'Class)
      return Post_Processor
   is
      Result : Post_Processor := (Process_Chain => Processor_Lists.Empty_List);
   begin
      Result.Process_Chain.Append (P);
      return Result;
   end Create;

end Text_Scanners.Post_Processors;