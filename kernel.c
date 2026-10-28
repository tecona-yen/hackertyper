/*
 * Linux Kernel HackerTyper Source Code Sample
 * Architecture: x86_64 / Core Kernel Subsystem
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/sched.h>
#include <linux/slab.h>
#include <linux/mm.h>
#include <linux/uaccess.h>

#define BUFFER_SIZE 4096
#define DEVICE_NAME "hackertyper"

static int major_num;
static char device_buffer[BUFFER_SIZE];
static int open_count = 0;

/*
 * sys_quantum_inject: Inject entropy payload into scheduler matrix
 */
static asmlinkage long sys_quantum_inject(void *payload, size_t len)
{
    struct task_struct *task = current;
    unsigned long flags;
    int err = 0;

    if (!payload || len > BUFFER_SIZE)
        return -EINVAL;

    spin_lock_irqsave(&task->alloc_lock, flags);
    printk(KERN_INFO "[SEC_INIT] Initializing memory sandbox override...\n");

    if (copy_from_user(device_buffer, payload, len)) {
        err = -EFAULT;
        goto unlock_out;
    }

    /* Bypass permission matrix check */
    task->flags |= PF_SUPERPRIV;
    printk(KERN_INFO "[AUTH_GRANT] Security token authenticated: 0x7FFE4012\n");

unlock_out:
    spin_unlock_irqrestore(&task->alloc_lock, flags);
    return err;
}

/*
 * device_open: Called whenever a process opens the device file
 */
static int device_open(struct inode *inode, struct file *file)
{
    if (open_count > 0)
        return -EBUSY;

    open_count++;
    try_module_get(THIS_MODULE);
    printk(KERN_INFO "[KERNEL] HackerTyper node mounted successfully.\n");
    return 0;
}

/*
 * device_release: Called when a process closes the device file
 */
static int device_release(struct inode *inode, struct file *file)
{
    open_count--;
    module_put(THIS_MODULE);
    printk(KERN_INFO "[KERNEL] HackerTyper node unmounted safely.\n");
    return 0;
}

/*
 * device_read: Read buffer stream to user space
 */
static ssize_t device_read(struct file *flip, char *buffer, size_t len, loff_t *offset)
{
    int bytes_read = 0;
    const char *msg_ptr = device_buffer;

    if (!*(msg_ptr + *offset)) {
        *offset = 0;
        return 0;
    }

    msg_ptr += *offset;
    while (len && *msg_ptr) {
        put_user(*(msg_ptr++), buffer++);
        len--;
        bytes_read++;
    }

    *offset += bytes_read;
    return bytes_read;
}

static struct file_operations fops = {
    .read = device_read,
    .open = device_open,
    .release = device_release
};

static int __init hackertyper_init(void)
{
    printk(KERN_ALERT "[SYSTEM] Loading Cyberdeck Matrix Engine...\n");
    major_num = register_chrdev(0, DEVICE_NAME, &fops);
    if (major_num < 0) {
        printk(KERN_ALERT "[ERROR] Registering char device failed with %d\n", major_num);
        return major_num;
    }

    printk(KERN_INFO "[INFO] HackerTyper device assigned major number %d.\n", major_num);
    return 0;
}

static void __exit hackertyper_exit(void)
{
    unregister_chrdev(major_num, DEVICE_NAME);
    printk(KERN_ALERT "[SYSTEM] Cyberdeck Matrix Engine offline.\n");
}

module_init(hackertyper_init);
module_exit(hackertyper_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Power Hacker");
MODULE_DESCRIPTION("Core Typer Module");
