/*
    Photo Phix by Ronin Giles
    Purpose: image loader script
    no modify/no transfer
*/
integer PHOTO_PHIX_CONFIG_START_LINE = 18;
list PHOTO_PHIX_SCREEN_LINKS = ["7", "9", "8"];

string gConfigFile;
list gConfigOptions;
integer gImageCount;
list gImageList;
integer gListenChannel;
integer gListenHandler;
key gRequestID;
key gUser;


/*
    Returns a list of all available config notecards.

    @return list config - Returns list of notecard options.
*/
list get_config_options()
{
    integer i;
    list config = [];
    for (i = 0; i <= (llGetInventoryNumber(INVENTORY_NOTECARD) - 1); i++)
    {
        string notecard = llGetInventoryName(INVENTORY_NOTECARD, i);

        if (notecard != "!phix.control.hlp")
        {
            config += notecard;
        }
    }
    return config;
}

set(integer page)
{
    integer c;
    integer limit = 3;  //six node version
    integer offset;
    if (page != 0)
    {
        offset = limit*page;
    }
    else
    {
        offset = 0;
    }
    for (c = 0; c < llGetListLength(PHOTO_PHIX_SCREEN_LINKS); c++)
    {
        key SDZ_KEY = llList2Key(gImageList, c + offset);
        if (SDZ_KEY != NULL_KEY)
        {
            llMessageLinked(llList2Integer(PHOTO_PHIX_SCREEN_LINKS, c), 202, "command:set", SDZ_KEY);
        }
        else
        {
            llMessageLinked(llList2Integer(PHOTO_PHIX_SCREEN_LINKS, c), 202, "command:reset", NULL_KEY);
        }
    }
    //tell other scripts the image total
    llMessageLinked(LINK_SET, gImageCount, "command:total", NULL_KEY);
}

set_listening_channel()
{
    gListenChannel = llFloor(llFrand(999999));
    gListenChannel = gListenChannel - (gListenChannel * 2);
}


//begin default state
default
{
    on_rez(integer StartParameter)
    {
        llResetScript();
    }

    state_entry()
    {
        set_listening_channel();
    }

    link_message(integer SendersLink, integer Value, string Text, key ID)
    {
        if (Value == 202 && llSubStringIndex(Text, "command:") != -1)
        {
            string command = llDeleteSubString(Text, 0, 7);
            if (command == "load")
            {
                gConfigOptions = get_config_options();
                if (llGetListLength(gConfigOptions) > 0)
                {
                    gUser = ID; //set active user
                    state PhotoPhixLoader;
                }
                else
                {
                    llOwnerSay("No notecards found...");
                }
            }
        }
    }
}

//begin PhotoPhixLoader state
state PhotoPhixLoader
{
    on_rez(integer StartParameter) { llResetScript(); }

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
        else
        {
            if (Text == "page")
            {
                set(Value - 1);
            }
        }
    }

    state_entry()
    {
        //no more images
        gImageList = [];
        gListenHandler = llListen(gListenChannel, "", gUser, "");
        llListenControl(gListenHandler, TRUE);
        llDialog(gUser, "Read lines from which notecard?", gConfigOptions, gListenChannel);
    }

    listen(integer Channel, string Name, key ID, string Text)
    {
        if (Channel == gListenChannel)
        {
            gConfigFile = Text;
            gRequestID = llGetNotecardLine(
                gConfigFile,
                PHOTO_PHIX_CONFIG_START_LINE
            );
            llOwnerSay("I am reading notecard \"" + gConfigFile + "\"...");
        }

        llListenControl(gListenHandler, FALSE);
    }

    dataserver(key RequestID, string Data)
    {
        if (RequestID == gRequestID)
        {
            if (Data != EOF)
            {
                if (Data != "")
                {
                    gImageList += Data;
                    ++PHOTO_PHIX_CONFIG_START_LINE;
                    gRequestID = llGetNotecardLine(
                        gConfigFile,
                        PHOTO_PHIX_CONFIG_START_LINE
                    );
                }
            }
            else
            {
                gImageCount = llGetListLength(gImageList);
                llMessageLinked(LINK_ROOT, gImageCount, "total", llGetOwner());
                llOwnerSay(
                    "I have read "
                    + (string)gImageCount
                    + " lines from \""+gConfigFile+"\"."
                );
                set(0);
            }
        }
    }
}
