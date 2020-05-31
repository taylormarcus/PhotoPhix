/*
    Photo Phix by Ronin Giles
    Purpose: frame script
    no modify/no transfer
*/
list PHOTO_PHIX_EXPAND_PARAMETERS = [<.084, .010, .084>, <.500, .010, .485>];

string gImageDescription;
string gImageTitle;
key gImageUUID;


default
{
    on_rez(integer StartParameter) { llResetScript(); }

    state_entry()
    {
        llSetAlpha(0.0, -1);
        llSetScale(llList2Vector(PHOTO_PHIX_EXPAND_PARAMETERS, 0));
    }

    link_message(integer SendersLink, integer Value, string Text, key ID)
    {
        if (Value == 202 && llSubStringIndex(Text, "command:") != -1)
        {
            string command = llDeleteSubString(Text, 0, 7);
            if (command == "reset")
            {
                llSetAlpha(0.0, -1);
                llSetScale(llList2Vector(PHOTO_PHIX_EXPAND_PARAMETERS, 0));
            }
        }

        if (Value == 505 && llSubStringIndex(Text, "command:") != -1)
        {
            string command = llDeleteSubString(Text, 0, 7);
            if (command == "hide")
            {
                llSetAlpha(0.0, -1);
                llSetScale(llList2Vector(PHOTO_PHIX_EXPAND_PARAMETERS, 0));
            }
        }

        if (Value == 303)
        {
            //(string)gImageUUID + ";" + gImageTitle + ";" + gImageDescription
            list pieces = llParseString2List(Text, [";"], []);
            gImageDescription = llList2String(pieces, 2);
            gImageUUID = llList2String(pieces, 0);
            gImageTitle = llList2String(pieces, 1);
            llSetAlpha(1.0, -1);
            llSetScale(llList2Vector(PHOTO_PHIX_EXPAND_PARAMETERS, 1));
            llMessageLinked(LINK_SET, 404, "command:" + (string)gImageUUID, "");
            llSleep(1.5);
            llMessageLinked(LINK_SET, 202,
                "InfoSet::" + gImageTitle +
                ";" + gImageDescription
                + ";" + (string)gImageUUID,
            "");
        }
    }
}
