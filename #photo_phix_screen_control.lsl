/*
    Photo Phix by Ronin Giles
    Purpose: expanding screen script
    no modify/no transfer
*/
list PHOTO_PHIX_EXPAND_PARAMETERS = [<.084, .010, .084>, <.485, .010, .470>];

integer gIsExpanded = 0;


//begin default state
default
{
    on_rez(integer StartParameter) { llResetScript(); }

    state_entry()
    {
        llSetAlpha(0.0, -1);
        llSetScale(llList2Vector(PHOTO_PHIX_EXPAND_PARAMETERS, 0));
        llSetTexture("48b5d981-4cdb-65cd-3562-9c1ad615f22a", -1);
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

        if (Value == 404 && llSubStringIndex(Text, "command:") != -1)
        {
            string command = llDeleteSubString(Text, 0, 7);
            gIsExpanded = 1;
            llSleep(1.0);
            llSetAlpha(1.0, -1);
            llSetScale(llList2Vector(PHOTO_PHIX_EXPAND_PARAMETERS, 1));
            llSetTexture(command, -1);
        }
    }

    touch_start(integer NumberOfTouches)
    {
        if (llDetectedKey(0) != llGetOwner())
            return;

        if (gIsExpanded == 1)
        {
            gIsExpanded = 0;
            llSetAlpha(0.0, -1);
            llSetScale(llList2Vector(PHOTO_PHIX_EXPAND_PARAMETERS, 0));
            llMessageLinked(LINK_SET, 505, "command:hide", "");
        }
    }
}
