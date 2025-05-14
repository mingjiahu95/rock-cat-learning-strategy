function keyboard_wait(keyName)
     while true
        [~, keyCode] = KbStrokeWait;
        if keyCode(KbName(keyName))
            break
        end
    end
end
