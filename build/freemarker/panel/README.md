# File naming convention
This conky suite physically separates the desktop configurations from the laptop ones.  
This is due to the logic of each conky being so different that having `if/else` blocks within the code to distinguish between the two devices would be too conversome and hard to maintain.

File names are used to distinguish between the two devices.  Any configurations withouth the `-<device>` prefix will be for desktop.  Laptop configurations should always make use of the suffix.  
If both devices use the same file name, use the suffix for both.

The `@outputFileDirective` freemarker macro is used to rename the output file.

# Conky design notes

## Working with monospace fonts
- Conky window size should be a multiple of the character width, ex. if char width is 6px then the window width can be 36, 90, ...
- Conky adds `1px` to the window width.  
You would not be able to tell unless you set the window type to `panel` mode
  and maximize another app.  Then the invisible pixel would show.
