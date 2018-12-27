def sum(arg):
    total = 0
    for val in arg:
        total += val
    return total

if __name__ == '__main__':
    total = sum([1,2,3])
    print(total)
