function lng = printPercDone(n, i)

percString = num2str(round((i/(n))*100,1));
lng = fprintf('%s %%', percString);