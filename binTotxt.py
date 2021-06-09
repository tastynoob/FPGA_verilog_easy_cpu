
import binascii

path = 'D:/Desktop/'


with open(path + 'out.bin','rb') as f:
    with open(path + 'out.list','w') as fs:
        while 1:
            byte = f.read(4)
            if not byte:
                break
            fs.write(str(byte.hex()) + '\n')
        