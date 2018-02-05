s = PL_InitClient(0);
if s == 0
   return
end
pause(0.05);
tim = zeros(4,10000);
sys_t = tic;
PL_GetTS(s);
n = 0;
while n == 0
    [n, t] = PL_GetTS(s);
end
offset_t = toc(sys_t);
offset = t(end,4) - offset_t;
disp(offset)
disp(t(end,4))
% get A/D data and plot it
for i = 1:10000
    n = 0;
    while n == 0
        [n, t] = PL_GetTS(s);
    end
    ti = toc(sys_t); 
    v = t(end,4) - t(1,4);
    tim(:,i) = [ti,t(end,4),t(end,4)-ti-offset,v];
end

% you need to call PL_Close(s) to close the connection
% with the Plexon server
PL_Close(s);
s = 0;