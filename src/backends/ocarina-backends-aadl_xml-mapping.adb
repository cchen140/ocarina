------------------------------------------------------------------------------
--                                                                          --
--                           OCARINA COMPONENTS                             --
--                                                                          --
--    O C A R I N A . B A C K E N D S . A A D L _ X M L . M A P P I N G     --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                   Copyright (C) 2011-2014 ESA & ISAE.                    --
--                                                                          --
-- Ocarina  is free software;  you  can  redistribute  it and/or  modify    --
-- it under terms of the GNU General Public License as published by the     --
-- Free Software Foundation; either version 2, or (at your option) any      --
-- later version. Ocarina is distributed  in  the  hope  that it will be    --
-- useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of  --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General --
-- Public License for more details. You should have received  a copy of the --
-- GNU General Public License distributed with Ocarina; see file COPYING.   --
-- If not, write to the Free Software Foundation, 51 Franklin Street, Fifth --
-- Floor, Boston, MA 02111-1301, USA.                                       --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable to be   --
-- covered  by the  GNU  General  Public  License. This exception does not  --
-- however invalidate  any other reasons why the executable file might be   --
-- covered by the GNU Public License.                                       --
--                                                                          --
--                 Ocarina is maintained by the TASTE project               --
--                      (taste-users@lists.tuxfamily.org)                   --
--                                                                          --
------------------------------------------------------------------------------

with Ocarina.Namet; use Ocarina.Namet;

with Ocarina.ME_AADL.AADL_Instances.Nodes;
with Ocarina.ME_AADL.AADL_Instances.Nutils;

with Ocarina.Backends.XML_Tree.Nodes;
with Ocarina.Backends.XML_Tree.Nutils;

package body Ocarina.Backends.AADL_XML.Mapping is

   use Ocarina.ME_AADL;
   use Ocarina.ME_AADL.AADL_Instances.Nodes;

   use Ocarina.Backends.XML_Tree.Nodes;
   use Ocarina.Backends.XML_Tree.Nutils;

   package AIN renames Ocarina.ME_AADL.AADL_Instances.Nodes;
   package AINU renames Ocarina.ME_AADL.AADL_Instances.Nutils;
   package XTN renames Ocarina.Backends.XML_Tree.Nodes;

   -----------------
   -- Map_HI_Node --
   -----------------

   function Map_HI_Node (E : Node_Id) return Node_Id is
      N : constant Node_Id := New_Node (XTN.K_HI_Node);
   begin
      pragma Assert (AINU.Is_Process (E)
                     or else AINU.Is_System (E)
                     or else AINU.Is_Processor (E));

      if AINU.Is_System (E) then
         Set_Str_To_Name_Buffer ("general");
      else
         Get_Name_String
           (To_XML_Name (AIN.Name (Identifier (Parent_Subcomponent (E)))));
         Add_Str_To_Name_Buffer ("_cheddar");
      end if;

      XTN.Set_Name (N, Name_Find);
      Set_Units (N, New_List (K_List_Id));

      --  Append the partition N to the node list

      Append_Node_To_List (N, HI_Nodes (Current_Entity));
      Set_Distributed_Application (N, Current_Entity);

      return N;
   end Map_HI_Node;

   -----------------
   -- Map_HI_Unit --
   -----------------

   function Map_HI_Unit (E : Node_Id)
      return Node_Id is
      U        : Node_Id;
      N        : Node_Id;
      P        : Node_Id;
      Root     : Node_Id;
   begin
      pragma Assert (AINU.Is_System (E)
                     or else AINU.Is_Process (E)
                     or else AINU.Is_Processor (E));

      U := New_Node (XTN.K_HI_Unit, Identifier (E));

      --  Packages that are common to all nodes

      if AINU.Is_System (E) then
         Get_Name_String (To_XML_Name (Display_Name (Identifier (E))));

      else
         Get_Name_String
           (To_XML_Name
              (Display_Name (Identifier (Parent_Subcomponent (E)))));
      end if;

      Add_Str_To_Name_Buffer ("_aadl_xml");
      N := Make_Defining_Identifier (Name_Find);

      P := Make_XML_File (N);
      Set_Distributed_Application_Unit (P, U);
      XTN.Set_XML_File (U, P);

      Root := Make_XML_Node ("", No_Name, K_Nameid);

      XTN.Set_Root_Node (P, Root);

      Append_Node_To_List (U, Units (Current_Entity));
      XTN.Set_Entity (U, Current_Entity);

      return U;
   end Map_HI_Unit;

end Ocarina.Backends.AADL_XML.Mapping;
