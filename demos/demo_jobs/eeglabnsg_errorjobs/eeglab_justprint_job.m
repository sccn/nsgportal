
for i=1:1000
    pause(30);
    format shortg;
    timeval = clock;
    disp(['Printed at ' num2str(timeval(2)) '-' num2str(timeval(3)) '-' num2str(timeval(1)) ' ' num2str(timeval(4)) ':'  num2str(timeval(5)) ':'  num2str(timeval(6)) ]);
    disp('');
end