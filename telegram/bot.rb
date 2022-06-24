require File.expand_path('../config/environment', __dir__)

require 'telegram/bot'

token="5523027415:AAHorTQTHwrKj1vbggySQez2bR-Scrhacxk"

Telegram::Bot::Client.run(token) do |bot|
    bot.listen do |message|
        if !User.exists?(telegram_id: message.from.id)
            user = User.create(telegram_id: message.from.id, name: message.from.first_name)
        else
            user = User.find_by(telegram_id: message.from.id)
        end

        case user.step
        when "add"
            Bot.create(username: message.text)
            user.step = "description" 
            user.save
            bot.api.send_message(chat_id: message.chat.id, text: "Send me bot description")
        when "description" 
           new_bot = user.bots.last
           new_bot.description = message.text
           new_bot.save
           bot.api.send_message(chat_id: message.chat.id, text: "Your bot has been saved!")
            user.step = nil
            user.save
        when "delete"
            if user.bots.map{ |u_bot| u_bot.username }.include?(message.text)
                Bot.find_by(username: message.text).destroy
                bot.api.send_message(chat_id: message.chat.id, text: "We deleted your bot!") 
            else
                bot.api.send_message(chat_id: message.chat.id, text: "We can't find your bot!") 
            end
            user.step = nil
            user.save
        when "search"
            bots = Bot.where("description LIKE ?", "%#{message.text}%")
            bot.api.send_message(chat_id: message.chat.id, text: "Search results:") 
            if !bots.size.zero?
                bots.each do |s_bot|
                    bot.api.send_message(chat_id: message.chat.id, text: "#{s_bot.username}:#{s_bot.description}") 
                end
            else
                bot.api.send_message(chat_id: message.chat.id, text: "We couldn't find anything for you ~")
            end
            user.step = nil
            user.save
        end

        case message.text
        when "/add"
            user.step = "add"
            user.save
            bot.api.send_message(chat_id: message.chat.id, text: "Send me bot username")
        when "/delete"
            user.step = "delete"
            user.save
            arr = user.bots.map{ |u_bot| u_bot.username}
            markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: arr)
            bot.api.send_message(chat_id: message.chat.id, text: "Pick a bot to delete", reply_markup: markup)
        when "/search"
            user.step = "search"
            user.save
            bot.api.send_message(chat_id: message.chat.id, text: "Send me a request")
        end
    end
end