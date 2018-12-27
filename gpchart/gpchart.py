'''
This is written for CI Test
'''
def sum_test(arg):
    '''
    Add all elements
    '''
    total = 0
    for val in arg:
        total += val
    return total

if __name__ == '__main__':
    print(sum([1, 2, 3]))
