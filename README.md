## Script UI made by i3ucky:
https://github.com/i3ucky/bucky_mdt

## Script Converted made by SalahKham:
https://github.com/WildWestLegends

## How to Install?

1. Make sure to rename to rsg-mdtmedic then ensure rsg-mdtmedic on your resources list. Can work together with mdt for police.
2. Run the user_mdt SQL in your database.
3. Inside the config will be able to change the jobs required to use the mdt.
4. To bring up the mdt use /mdt in chat (this can be changed in config) and itll bring up the mdt with an animation as if you were pulling out a notebook or notepad.

## Example
![pic1](https://cdn.discordapp.com/attachments/963010990373494845/1095199625922744349/Screenshot_24.png)

For use through radial menu add code snippet thats below in rsg-radialmenu\config.lua after line 302 (lawbadge)
 
{
            id = 'mdt',
            title = 'MDT For Medics',
            icon = 'mobile-screen',
            type = 'command',
            event = 'mdt',
            shouldClose = true
        },
