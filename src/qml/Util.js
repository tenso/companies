.pragma library

function newArray(len, initial) {
    var i;
    var a = [];
    for (i = 0; i < len; i++) {
        a[i] = initial;
    }
    return a;
}

function max(array) {
    return array.reduce(function(a,b) { return Math.max(a, b);});
}

function sort(array, ascending) {
    if (ascending) {
        array.sort(function(a,b) { return a-b;});
    }
    else {
        array.sort(function(a,b) { return b-a;});
    }
}
