/*
    Photo Phix by Ronin Gilez
    Purpose: browse menu
    no modify/no transfer
*/
integer gChapter = 0;   //holds value for chosen chapter number for sending
integer gImageCount = 0;    //the number of UUIDs read from notecard
integer gListenerChannel = 0;    //holds info for listening channel
integer gListenerHandler = 0;    //listen handler
integer gPage = 0;    //holds value for chosen page number for sending


browse(key avatar)
{
    //if no number loaded, return
    if (gImageCount < 1) return;

    //stats
    string pages = (string)llGetListLength(get_page_listing());    //3 images per page
    string uuids = (string)gImageCount;

    //message
    string message = "Loaded UUIDs: "+uuids+"\nPages: "+pages+"\n";

    list menu;
    menu = get_page_listing();
    llListen(-31242356, "", avatar, "");
    llDialog(avatar, message, menu, -31242356);
}

/*
    Returns pagination listing

    @return list pgmenu - List of available pages.
*/
list get_page_listing()
{
    list pgmenu;
    integer pg = gImageCount/3;
    if (gImageCount % 3)
    {
        pg = pg + 1;
    }
    integer i;
    for (i = 1; i <= pg; i++)
    {
        pgmenu += "Page " + (string)i;
    }
    return pgmenu;
}

/*
    @param key avatar
    @param string input
*/
sub_browse(key avatar, string input)
{
    //stats
    string pages = (string)llGetListLength(get_page_listing());    //3 images per page
    string uuids = (string)gImageCount;

    //message
    string message = "Loaded UUIDs: " + uuids + "\nPages: " + pages + "\n";

    gChapter = (integer)llDeleteSubString(input, 0, 4);
    if (gChapter == 1)
    {
        gPage = 0;
    }
    else
    {
        gPage = gChapter * 11 - 11 + 1;
    }

    list menu = llList2ListStrided(get_page_listing(), gPage, gPage + 11, 1);
    llListen(-31242356, "", avatar, "");
    llDialog(avatar, message, menu, -31242356);
}

default
{
    on_rez(integer StartParameter) { llResetScript(); }

    link_message(integer SendersLink, integer Value, string Text, key _mine)
    {
        if (Value == 202 && llSubStringIndex(Text, "command:") != -1)
        {
            string cmd = llDeleteSubString(Text, 0, 7);
            if (cmd == "browse")
            {
                browse(_mine);
            }
        }
        else if (SendersLink == LINK_ROOT && Text == "total")
        {
            gImageCount = Value;
        }
    }

    listen(integer Channel, string Name, key ID, string Text)
    {
        //responds on main menu channel
        if (Channel == gListenerChannel)
        {
            //if chapter
            if (llSubStringIndex(Text, "Chap ") != -1)
            {
                sub_browse(ID, Text);
            }
            llListenRemove(gListenerHandler);
        }

        //response on sub menu channel
        if (Channel == -31242356)
        {
            //if page
            if (llSubStringIndex(Text, "Page ") != -1)
            {
                //llOwnerSay((string)gPage);
                gPage = (integer)llDeleteSubString(Text, 0, 4);
                llMessageLinked(LINK_ROOT, gPage, "page", "");
            }
        }
    }
}
