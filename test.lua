path.bilibili_login = {
    B服安全验证 = disable_game_up_check_wrapper(function()
        log("开始B服安全验证流程")
        

        -- 这段有点屎，不应该放在主流程里，但是为了兼容先不动他
        local box = findOne("B服安全验证框")
        -- log("box", box)
        if not box then
            log("B服安全验证流程", "B服安全验证框未找到")
            return
        end
        box = box.bounds

        -- log("b服打码")
        local choices = {}
        if use_captcha_aunly and type(cloud_captcha_token) == "string" and #cloud_captcha_token > 10 then
            table.insert(choices, 3)
        end
        if use_captcha_free2 and type(cloud_captcha_server2) == "string" and #cloud_captcha_server2 > 4then
            table.insert(choices, 4)
        end
        if use_captcha and captcha_username then
            table.insert(choices, 1)
        end
        
         log("B服安全验证流程", "安全验证流程结束")
    end),
    
}