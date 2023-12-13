function newButton(text,fn)
    return {
        text = text,
        fn = fn,

        now = false,
        last=false
    }
end