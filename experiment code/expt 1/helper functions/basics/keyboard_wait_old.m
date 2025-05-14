function keyboard_wait(keyName)
    while true
        [~, ~, keyCode] = KbCheck;
        if keyCode(KbName(keyName))
            break
        end
    end
    while KbCheck; end %wait for key release
end
