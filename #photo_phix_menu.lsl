//Photo Phix by Ronin Giles
//Purpose: menu script
//no modify/no transfer
integer gActive = 0;
list gOptions;

default
{
    on_rez(integer StartParameter) { llResetScript(); }

    changed(integer Changed)
    {
        if (Changed & CHANGED_INVENTORY)
        {
            llMessageLinked(LINK_SET, 202, "command:reset", "");
            llResetScript();
        }
    }

    link_message(integer SendersLink, integer Value, string Text, key ID)
    {
        if (Value == 202 && llSubStringIndex(Text, "command:") != -1)
        {
            string command = llDeleteSubString(Text, 0, 7);
            if (command == "reset")
            {
                llResetScript();
            }
        }
    }

    touch_start(integer NumberOfTouches)
    {
        if (llDetectedKey(0) == llGetOwner())
        {
            if (gActive == 0)
            {
                gOptions = ["Load"];
            }
            else if (gActive == 1)
            {
                gOptions = ["Browse", "Reset"];
            }

            llListen(-19283847, "", llGetOwner(), "");
            llDialog(llGetOwner(), "Please select an option.", gOptions, -19283847);
        }
    }

    listen(integer Channel, string Name, key ID, string Text)
    {
        if (Channel != -19283847)
            return;

        //browse option
        if (Text == "Browse")
        {
            llMessageLinked(LINK_ROOT, 202, "command:browse", ID);
        }

        //load option
        if (Text == "Load")
        {
            gActive = 1;
            llMessageLinked(LINK_ROOT, 202, "command:load", ID);
            llShout(-13467929, "command:reset");
        }

        //reset option
        if (Text == "Reset")
        {
            gActive = 0;
            llMessageLinked(LINK_SET, 202, "command:reset", ID);
        }
    }
}
