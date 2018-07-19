#include "nwnx_chat"#include "nwnx_lua"
void main()
{
    //Lua
    NWNX_Lua_RunEvent("mod_chat", GetPCChatSpeaker());

}

