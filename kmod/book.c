#include <linux/init.h>

#include <linux/module.h>

 

static char *bookName = "Good Book.";

static int bookNumber = 100;

 

static int __init book_init(void)

{

         printk(KERN_INFO "Book name is %s\n", bookName);

         printk(KERN_INFO "Book number is %d\n", bookNumber);

         return 0;

}

 

static void __exit book_exit(void)

{

         printk(KERN_INFO "Book module exit.\n");

}

 

module_init(book_init);

module_exit(book_exit);

module_param(bookName, charp, S_IRUGO);

module_param(bookNumber, int, S_IRUGO);

 

MODULE_LICENSE("GPL");
