

    ////////////////////////////////////////////////////////////////////////////
    ///  Temporary solution for REGN Points
    ////////////////////////////////////////////////////////////////////////////
    if elementpathstring = 'Region Data Entries\Region Data Entry\RDAT\Type' then
    begin
      AddMessage(GetElementEditValues(subrec, 'Type'));
      subrec_container := GetContainer(subrec_container); // Region Data Entries\Region Data Entry
      elementinteger := IndexOf(rec, GetContainer(subrec_container));
      subrec := Nil;
      case (StrToInt(elementvaluestring)) of
//        6 : subrec := RecordByFormID(FileByIndex(0), $000138DE, True); // Grass
//        8 : subrec := RecordByFormID(FileByIndex(0), $000138DE, True); // Imposter
        5 : subrec := RecordByFormID(FileByIndex(0), $00059FC3, True); // Land
        4 : subrec := RecordByFormID(FileByIndex(0), $0018DFCF, True); // Map
        2 : subrec := RecordByFormID(FileByIndex(0), $00076A59, True); // Objects
        7 : subrec := RecordByFormID(FileByIndex(0), $00068D60, True); // Sound
        3 : subrec := RecordByFormID(FileByIndex(0), $00001171, True); // Weather
      end;
      if Assigned(subrec) then
      begin
        if ElementCount(GetContainer(subrec_container)) = 1 then
        begin
          Remove(GetContainer(subrec_container));
          subrec := ElementByPath(subrec, 'Region Data Entries');
          subrec := ElementAssign(rec, elementinteger, subrec, False);
          if ElementCount(subrec) > 1 then
            for k := (ElementCount(subrec) - 1) downto 1 do
              Remove(ElementByIndex(subrec, k));
          subrec := ElementByPath(subrec, 'Region Data Entry\RDAT\Type');
        end
        else
        begin
          subrec := ElementByPath(subrec, 'Region Data Entries');
          subrec := ElementByIndex(subrec, 0);
          subrec := ElementAssign(GetContainer(subrec_container), MaxInt, subrec, False);
          Remove(subrec_container);
          subrec := ElementByPath(subrec, 'RDAT\Type');
        end;
      end;
    end;