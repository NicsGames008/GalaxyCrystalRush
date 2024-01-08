-- Function to create a new button object
function newButton(text, fn)
    -- Create and return a new button object with specified properties
    return {
        text = text,  -- Text to be displayed on the button
        fn = fn,      -- Function to be called when the button is pressed

        now = false,  -- Current state of the button (pressed or not pressed)
        last = false   -- Previous state of the button
    }
end
