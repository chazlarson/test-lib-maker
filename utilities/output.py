def show_title(bits):
    # group|Beverly Hills Cop|4
    print("===============================================")
    print(f"Creating {bits[2]} items for {bits[1]}")
    print("===============================================")

def show_footer(complete, target):
    print("===============================================")
    print(f"Created {complete} items of expected {target}")
    print("===============================================")

def is_a_media_line(bits):
    # ['Beverly Hills Cop', '1984']
    return len(bits) >= 2 and bits[1].isnumeric()
