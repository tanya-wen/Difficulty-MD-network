function [question, answer, choices] = question_generator(level)

    if level == 1
        a = 9; b = 9;
        while (isnan(str2double(a(1)) + str2double(b(1))) || str2double(a(1)) + str2double(b(1)) > 10)
            a = string(floor(rand * 9 + 1));
            b = string(floor(rand * 9 + 1));
            question = a + " + " + b + " = ";
            answer = str2double(a) + str2double(b);
            lures = shuffle([+1, -1, +10]);
            choices = shuffle([answer, answer+lures(1), answer+lures(2)]);
        end
    elseif level == 2
        a = 0; b = 0;
        while (isnan(str2double(a(1)) + str2double(b(1))) || str2double(a(1)) + str2double(b(1)) < 10)
            a = string(floor(rand * 9 + 1));
            b = string(floor(rand * 90 + 10));
            question = a + " + " + b + " = ";
            answer = str2double(a) + str2double(b);
            lures = shuffle([+1, -1, +10, -10]);
            choices = shuffle([answer, answer+lures(1), answer+lures(2)]);
        end
    elseif level == 3 || level == 4
        a = 0; b = 0;
        while (isnan(str2double(a(1)) + str2double(b(1))) || str2double(a(1)) + str2double(b(1)) < 10)
            a = string(floor(rand * 90 + 10));
            b = string(floor(rand * 90 + 10));
            question = a + " + " + b + " = ";
            answer = str2double(a) + str2double(b);
            lures = shuffle([+1, -1, +10, -10]);
            choices = shuffle([answer, answer+lures(1), answer+lures(2)]);
        end
    elseif level == 5
        a = 0; b = 0;
        while (isnan(str2double(a(1)) + str2double(b(1))) || str2double(a(1)) + str2double(b(1)) < 10)
            a = string(floor(rand * 90 + 10));
            b = string(floor(rand * 900 + 100));
            question = a + " + " + b + " = ";
            answer = str2double(a) + str2double(b);
            lures = shuffle([+1, -1, +10, -10, +100, -100]);
            choices = shuffle([answer, answer+lures(1), answer+lures(2)]);
        end
    elseif level == 6
        a = 0; b = 0;
        while (isnan(str2double(a(1)) + str2double(b(1))) || str2double(a(1)) + str2double(b(1)) < 10)
            a = string(floor(rand * 900 + 100));
            b = string(floor(rand * 900 + 100));
            question = a + " + " + b + " = ";
            answer = str2double(a) + str2double(b);
            lures = shuffle([+1, -1, +10, -10, +100, -100]);
            choices = shuffle([answer, answer+lures(1), answer+lures(2)]);
        end
    end

end

