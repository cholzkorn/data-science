# x is the vector of asset values
# mode defines the characteristic to be calculated

def cvar(x, measure="var95"):
    x_returns = [0] * (len(x)-1)
    
    for i in range(0,(len(x)-1)):
        x_returns[i] = (x[i]-x[i+1])/x[i]
    
    total_count = len(x_returns)
    
    ## VAR AND CVAR .95
    
    if measure == "var95":
        var95_index = (1-0.95)/total_count
        var95 = x_returns[round(var95_index)]
        return(var95)
    
    elif measure == "cvar95":
        var95_index = (1-0.95)/total_count
        var95 = x_returns[round(var95_index)]
        cvar95 = (1/var95_index)*sum(x_returns[0:round(var95_index)+1])
        return(cvar95)
    
    ## VAR AND CVAR .99
    
    elif measure == "var99":
        var99_index = (1-0.99)/total_count
        var99 = x_returns[round(var99_index)]
        return(var99)
    
    elif measure == "cvar99":
        var99_index = (1-0.99)/total_count
        var99 = x_returns[round(var99_index)]
        cvar99 = (1/var99_index)*sum(x_returns[0:round(var99_index)+1])
        return(cvar99)
    
    ## VAR AND CVAR .999
    
    elif measure == "var999":
        var999_index = (1-0.999)/total_count
        var999 = x_returns[round(var999_index)]
        return(var999)
    
    elif measure == "cvar999":
        var999_index = (1-0.999)/total_count
        var999 = x_returns[round(var999_index)]
        cvar999 = (1/var999_index)*sum(x_returns[0:round(var999_index)+1])
        return(cvar999)
    
    ## error handling
    else:
        print("x must be a numeric array, measure must be var95, var99, var999, cvar95, cvar99 or cvar999")
