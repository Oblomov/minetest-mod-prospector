Prospector mod
==============

Description
-----------

This mod provides a prospecting kit, that combines the capabilities of the mapping kit
and binoculars, enables radar view in the minimap, and can give hints about the location
of hidden ores.

The kit is built combining the mapping kit, binoculars, and two prospecting
lenses, assembled from 4 gold ingots, 4 diamond and 1 mese crystal each.

Recipes:

Lens::

        GDG
        DMD
        GDG

Kit::

        LBL
         M

where L is the lens, B the binoculars, M the mapping kit.

When the prospecting kit is in the (main) inventory, the minimap can be enabled
with the appropriate key (cycling through both aerial and radar views),
and the user can use zoom view (with a FOV that is even smaller than
the one provided by the binoculars).

Using the prospecting kit will make all surrounding ores emit glowing particles
that float towards the user. Using this feature will provisionally disable all
uses of the kit (including mapping and binoculars) for a few seconds.

The recovery time and the range of the detection function can be set via the
config options ``prospector.recovery_time`` and ``prospector.show_ores_range``.
Setting ``prospector.show_ores_range`` to 0 disables the ore detection feature
altogether.

License
-------
The source code is published under the Creative Commons 0 (CC0) 1.0
Universal license (the closest thing to a formal dedication to the
public domain), as detailed in license-cc0.txt or
https://creativecommons.org/publicdomain/zero/1.0/

The lens textures is licensed under Creative Commons Attribution-ShareAlike
(CC BY-SA) 4.0 as details in license-cc-by-sa-3.txt or
https://creativecommons.org/licenses/by-sa/4.0/

