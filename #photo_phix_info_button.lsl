//Photo Phix by Ronin Giles
//Purpose: info display script
//no modify/no transfer
list gImageMetadata;
key gImageUUID;
integer gIsActive = 0;

default
{
    on_rez(integer StartParameter) { llResetScript(); }

    state_entry() { llSetAlpha(0.0, ALL_SIDES); }

    link_message(integer SendersLink, integer Value, string Text, key ID)
    {
        if (Value == 202 && llSubStringIndex(Text, "InfoSet::") != -1)
        {
            string command = llDeleteSubString(Text, 0, 7);
            if (command != "reset" && command != "update")
            {
                gIsActive = 1;
                gImageMetadata = llParseString2List(command, [";"], []);
                gImageUUID = ID;
                llSetAlpha(1.0, ALL_SIDES);
            }
            else
            {
                gIsActive = 0;
                gImageMetadata = [];
                gImageUUID = NULL_KEY;
                llSetAlpha(0.0, -1);
            }
        }

        if (Value == 505 && llSubStringIndex(Text, "command:") != -1)
        {
            string command = llDeleteSubString(Text, 0, 7);
            if (command == "hide")
            {
                gIsActive = 0;
                llSetAlpha(0.0, ALL_SIDES);
            }
        }
    }

    touch_start(integer NumberOfTouches)
    {
        if (gIsActive == 1 && llGetListLength(gImageMetadata))
        {
            llDialog(llDetectedKey(0),
                "Image Information\n\n"
                + "Name: " + llList2String(gImageMetadata, 0) + "\n"
                + "Description: " + llList2String(gImageMetadata, 1) + "\n"
                + "URL: http://secondlife.com/app/image/" + (string)gImageUUID + "/1",
            ["Thank you"], 12);
        }
    }
}
