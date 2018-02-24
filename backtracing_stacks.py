import gdb

def get_reg_value(reg):
    reg = gdb.execute("info registers %s" %(reg), to_string=True)
    if reg:
        reg = reg.splitlines()
        if len(reg) > 1:
            return None
        else:
            result = int(reg[0].split()[1],0)
            return result
    return reg

def get_fn_address(fn):
    fn = str(gdb.parse_and_eval(fn))
    fn = fn[len("{<text variable, no debug info>} "):]
    fn = fn.split(" ")[0]
    return int(fn, 16)

def get_var_address(var):
    var = str(gdb.parse_and_eval(var))
    var = var.split(" ")[0]
    return int(var, 16)

def backtrace_stack():
        i = 0
        frame = gdb.selected_frame()
        while frame != None and frame.is_valid() and frame.pc() > 0:
            pc = frame.pc()
            line = gdb.find_pc_line(pc)
            block = gdb.block_for_pc(pc)
            print("#{} 0x{:016x} in {}()+{} at {}:{}".format(i, pc, block.function, pc-block.start, line.symtab, line.line))
            i += 1
            frame = frame.older()

        if frame and frame.pc() > 0:
            print("Stopped because: {}".format(frame.unwind_stop_reason()))
        elif frame.pc() == 0:
            print("Stopped because pc = 0")
        elif frame == None:
            print("Stopped because frame = None")
        else:
            print("Stopped for unknown reason")
        print("")

class BacktrackingStacks(gdb.Command):
    def __init__(self):
        super(BacktrackingStacks, self).__init__ ("bts", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        print("Current Stack:")
        backtrace_stack()

        print("Attempting to jump frame 'within' stack")
        asmfoo = get_fn_address("asmfoo")
        rsp = get_reg_value("rsp")
        #that +40 is implicit knowledge 
        cmd = "select-frame {} {}".format(hex(int(rsp)+40), hex(asmfoo))
        gdb.execute(cmd)
        backtrace_stack()

        print("Attempting to jump frame 'outof' stack")
        old_stack = get_var_address("old_stack")
        switch_stack = get_fn_address("switch_stack")
        print("Old Stack: {} PC Address {}".format(hex(old_stack), hex(switch_stack)))
        old_frame_address = hex(int(old_stack) + 64)
        print("Frameline is +64: {}".format(old_frame_address))
        cmd = "select-frame {} {}".format(old_frame_address, hex(int(switch_stack)))
        print("Switching Stacks: {}".format(cmd))
        gdb.execute(cmd)

        print("Old Stack:")
        backtrace_stack()


BacktrackingStacks()
