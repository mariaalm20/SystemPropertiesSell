/*
Bosco - RA117873
Mafe - RA118597
Vitor Grabski - RA98369
*/


.section .data
    menu_str: .asciz "\n1. Inserção\n2. Remoção\n3. Consulta\n4. Gravar\n5. Recuperar\n6. Relatório\n0. Sair\n"
    name_str: .asciz "Nome do proprietário: "
    cell_str: .asciz "Celular do proprietário: "
    property_str: .asciz "Tipo do imóvel: "
    address_str: .asciz "Endereço do imóvel: "
    rooms_str: .asciz "Número de quartos: "
    garage_str: .asciz "Garagem: "
    area_str: .asciz "Metragem total: "
    rent_str: .asciz "Valor do aluguel: "
    save_success: .asciz "Registros salvos com sucesso!\n"
    load_success: .asciz "Registros carregados com sucesso!\n"
    remove_success: .asciz "Último registro removido com sucesso!\n"

    num_str: .asciz "%d%*c"  # joga fora newline do buffer
    nl_str: .asciz "\n"
    str_display: .asciz "%s\n"
    num_display: .asciz "%d\n"

    choice: .int 0
    name_input: .space 32
    cell_input: .space 32
    property_input: .space 32
    address_input: .space 32
    rooms_input: .int 0
    garage_input: .space 8
    area_input: .int 0
    rent_input: .int 0

    head: .int 0
    node_size: .int 152

    filename: .asciz "records.dat"

.section .bss
    .lcomm filehandle, 4
    .lcomm buffer, 152

.section .text
.globl _start
_start:
    call menu

    jmp _start

menu:
    # show options menu
    pushl $menu_str
    call printf
    addl $4, %esp

    # get user choice
    pushl $choice
    pushl $num_str
    call scanf
    addl $8, %esp

    # print nl
    pushl $nl_str
    call printf
    addl $4, %esp

    # call appropriate function
    cmpl $0, choice
    je quit
    cmpl $1, choice
    je insert
    cmpl $2, choice
    je remove
    cmpl $3, choice
    je query
    cmpl $4, choice
    je save
    cmpl $5, choice
    je load
    cmpl $6, choice
    je report

    ret

quit:
    pushl $0
    call exit

insert:
    # get name ----------------------------------------------------------------
    pushl $name_str
    call printf
    addl $4, %esp

    pushl stdin
    pushl $32
    pushl $name_input
    call fgets
    addl $12, %esp

    # get string length
    pushl $name_input
    call strlen  # returns first NUL offset
    addl $4, %esp

    # remove newline
    subl $1, %eax  # set offset to newline
    movl $name_input, %edi
    addl %eax, %edi  # offsets string address to newline address
    movb $0, (%edi)  # replaces newline with NUL

    # get cell phone ----------------------------------------------------------
    pushl $cell_str
    call printf
    addl $4, %esp

    pushl stdin
    pushl $32
    pushl $cell_input
    call fgets
    addl $12, %esp

    # get string length
    pushl $cell_input
    call strlen  # returns first NUL offset
    addl $4, %esp

    # remove newline
    subl $1, %eax  # set offset to newline
    movl $cell_input, %edi
    addl %eax, %edi  # offsets string address to newline address
    movb $0, (%edi)  # replaces newline with NUL

    # get property type -------------------------------------------------------
    pushl $property_str
    call printf
    addl $4, %esp

    pushl stdin
    pushl $32
    pushl $property_input
    call fgets
    addl $12, %esp

    # get string length
    pushl $property_input
    call strlen  # returns first NUL offset
    addl $4, %esp

    # remove newline
    subl $1, %eax  # set offset to newline
    movl $property_input, %edi
    addl %eax, %edi  # offsets string address to newline address
    movb $0, (%edi)  # replaces newline with NUL

    # get address -------------------------------------------------------------
    pushl $address_str
    call printf
    addl $4, %esp

    pushl stdin
    pushl $32
    pushl $address_input
    call fgets
    addl $12, %esp

    # get string length
    pushl $address_input
    call strlen  # returns first NUL offset
    addl $4, %esp

    # remove newline
    subl $1, %eax  # set offset to newline
    movl $address_input, %edi
    addl %eax, %edi  # offsets string address to newline address
    movb $0, (%edi)  # replaces newline with NUL

    # get rooms ---------------------------------------------------------------
    pushl $rooms_str
    call printf
    addl $4, %esp

    pushl $rooms_input
    pushl $num_str
    call scanf
    addl $8, %esp

    # get garage --------------------------------------------------------------
    pushl $garage_str
    call printf
    addl $4, %esp

    pushl stdin
    pushl $32
    pushl $garage_input
    call fgets
    addl $12, %esp

    # get string length
    pushl $garage_input
    call strlen  # returns first NUL offset
    addl $4, %esp

    # remove newline
    subl $1, %eax  # set offset to newline
    movl $garage_input, %edi
    addl %eax, %edi  # offsets string address to newline address
    movb $0, (%edi)  # replaces newline with NUL

    # get area ----------------------------------------------------------------
    pushl $area_str
    call printf
    addl $4, %esp

    pushl $area_input
    pushl $num_str
    call scanf
    addl $8, %esp

    # get rent ----------------------------------------------------------------
    pushl $rent_str
    call printf
    addl $4, %esp

    pushl $rent_input
    pushl $num_str
    call scanf
    addl $8, %esp

    # inserts all in node in list
    call ll_insert

    ret

ll_insert:
    movl $0, %esi  # trailing edi
    movl head, %edi

    # check if no nodes
    cmpl $0, head
    je _link

    _traverse:
    # check if correct position based on number of rooms
    cmpl $0, %edi
    je _link  # if new node is last
    movl rooms_input, %eax
    cmpl %eax, 132(%edi)  # new node's rooms greater than next node
    jle _link  # new node between nodes at esi and edi

    # next node
    movl %edi, %esi
    movl (%edi), %edi
    jmp _traverse

    # create new node
    _link:
    pushl node_size
    call malloc
    addl $4, %esp
    movl $0, (%eax)  # clears "next" pointer in case of preceding remove execution

    # set head
    cmpl $0, %esi
    jne _skip_head  # no head to set because new node is not first element
    movl %eax, head
    jmp _skip_next  # new node is first element, no previous node's "next" to set
    _skip_head:

    # set previous node's "next"
    cmpl $0, %esi
    je _skip_next
    movl %eax, (%esi)  # new node as previous node's next
    _skip_next:

    # set new node's "next"
    cmpl $0, %edi
    je _skip_next3
    movl %edi, (%eax)  # previous node's next to new node's next
    _skip_next3:

    # insert name
    movl $name_input, %esi
    movl %eax, %edi
    addl $4, %edi
    movl $32, %ecx
    rep movsb

    # insert cell
    movl $cell_input, %esi
    movl $32, %ecx
    rep movsb

    # insert property type
    movl $property_input, %esi
    movl $32, %ecx
    rep movsb

    # insert address
    movl $address_input, %esi
    movl $32, %ecx
    rep movsb

    # insert rooms
    movl rooms_input, %eax  # mem with mem
    movl %eax, (%edi)

    # insert garage
    movl $garage_input, %esi
    addl $4, %edi  # skip rooms field
    movl $8, %ecx
    rep movsb

    # insert area
    movl area_input, %eax  # mem with mem
    movl %eax, (%edi)

    # insert rent
    movl rent_input, %eax  # mem with mem
    movl %eax, 4(%edi)

    ret

remove:
    movl $0, %esi
    movl head, %edi

    _traverse1:
    # check if last node
    cmpl $0, (%edi)
    je _last_node1

    # next node
    movl %edi, %esi  # store 2nd to last node
    movl (%edi), %edi
    jmp _traverse1

    # set "next" to 0 for 2nd to last node
    _last_node1:
    cmpl $0, %esi
    je _skip_next1  # if only 1 node
    movl $0, (%esi)
    _skip_next1:

    #set head to 0 if only 1 node
    cmpl $0, %esi
    jne _skip_head1  # if more than 1 node
    movl $0, head
    _skip_head1:

    # free last node pointer
    pushl %edi
    call free
    addl $4, %esp

    # success message
    pushl $remove_success
    call printf
    addl $4, %esp

    ret

query:
    # get rooms
    pushl $rooms_str
    call printf
    addl $4, %esp
    pushl $rooms_input
    pushl $num_str
    call scanf
    addl $8, %esp

    movl head, %esi

    _loop2:
    # print if query satisfied, else loop
    movl rooms_input, %eax
    cmpl %eax, 132(%esi)
    jne _skip_print  # if not number of rooms

    pushl %esi  # back up start of node
    addl $4, %esi

    # [start] move strings from struct to inputs ------------------------------
    movl $name_input, %edi
    movl $32, %ecx
    rep movsb  # changes value of esi, hence backup

    movl $cell_input, %edi
    movl $32, %ecx
    rep movsb

    movl $property_input, %edi
    movl $32, %ecx
    rep movsb

    movl $address_input, %edi
    movl $32, %ecx
    rep movsb

    movl (%esi), %eax  # mem with mem
    movl %eax, rooms_input

    addl $4, %esi  # skip rooms field
    movl $garage_input, %edi
    movl $8, %ecx
    rep movsb

    movl (%esi), %eax  # mem with mem
    movl %eax, area_input

    movl 4(%esi), %eax  # mem with mem
    movl %eax, rent_input
    # [end] move strings from struct to inputs --------------------------------

    # print name
    pushl $name_str
    call printf
    addl $4, %esp
    pushl $name_input
    pushl $str_display
    call printf
    addl $8, %esp

    # print cell
    pushl $cell_str
    call printf
    addl $4, %esp
    pushl $cell_input
    pushl $str_display
    call printf
    addl $8, %esp

    # print property type
    pushl $property_str
    call printf
    addl $4, %esp
    pushl $property_input
    pushl $str_display
    call printf
    addl $8, %esp

    # print address
    pushl $address_str
    call printf
    addl $4, %esp
    pushl $address_input
    pushl $str_display
    call printf
    addl $8, %esp

    # print rooms
    pushl $rooms_str
    call printf
    addl $4, %esp
    pushl rooms_input
    pushl $num_display
    call printf
    addl $8, %esp

    # print garage
    pushl $garage_str
    call printf
    addl $4, %esp
    pushl $garage_input
    pushl $str_display
    call printf
    addl $8, %esp

    # print area
    pushl $area_str
    call printf
    addl $4, %esp
    pushl area_input
    pushl $num_display
    call printf
    addl $8, %esp

    # print rent
    pushl $rent_str
    call printf
    addl $4, %esp
    pushl rent_input
    pushl $num_display
    call printf
    addl $8, %esp

    popl %esi  # restore start of node

    _skip_print:
    # next node if exists
    cmpl $0, (%esi)
    je _end_print1

    movl (%esi), %esi  # next node

    jmp _loop2  # print again
    _end_print1:

    ret

save:
    # open file for write
    movl $5, %eax
    movl $filename, %ebx
    movl $11101, %ecx
    movl $0777, %edx
    int $0x80
    movl %eax, filehandle

    movl head, %esi

    _loop3:
    # write node to file
    movl $4, %eax
    movl filehandle, %ebx
    movl %esi, %ecx
    movl node_size, %edx
    int $0x80

    # next node if exists
    cmpl $0, (%esi)
    je _end_save  # if no next node, don't iterate again
    movl (%esi), %esi  # next node
    jmp _loop3  # write to file again
    _end_save:

    # close file
    movl $6, %eax
    movl $filename, %ebx
    int $0x80

    # success message
    pushl $save_success
    call printf
    addl $4, %esp

    ret

load:
    # open file for read
    movl $5, %eax
    movl $filename, %ebx
    movl $00, %ecx
    movl $0777, %edx
    int $0x80
    movl %eax, filehandle

    movl $0, head  # reset head

    _loop4:
    # create node
    pushl node_size
    call malloc
    addl $4, %esp
    movl %eax, %edi

    # set previous next pointer
    cmpl $0, head
    je _skip_next2
    movl %edi, (%esi)  # esi contains previous node's address
    _skip_next2:

    # set head if not set
    cmpl $0, head
    jne _skip_head2
    movl %eax, head
    _skip_head2:

    # write to newly allocated memory
    movl $3, %eax
    movl filehandle, %ebx
    movl %edi, %ecx
    movl node_size, %edx
    int $0x80

    # next node if exists
    cmpl $0, (%edi)
    je _end_save2  # if no next node, don't iterate again
    movl %edi, %esi  # save last node in esi for next iteration
    jmp _loop4  # read next node
    _end_save2:

    # close file
    movl $6, %eax
    movl $filename, %ebx
    int $0x80

    pushl $load_success
    call printf
    addl $4, %esp

    ret

report:
    movl head, %esi

    # return if no records
    cmpl $0, head
    je _end_print

    _loop1:
    pushl %esi  # back up start of node
    addl $4, %esi

    # [start] move strings from struct to inputs ------------------------------
    movl $name_input, %edi
    movl $32, %ecx
    rep movsb  # changes value of esi, hence backup

    movl $cell_input, %edi
    movl $32, %ecx
    rep movsb

    movl $property_input, %edi
    movl $32, %ecx
    rep movsb

    movl $address_input, %edi
    movl $32, %ecx
    rep movsb

    movl (%esi), %eax  # mem with mem
    movl %eax, rooms_input

    addl $4, %esi  # skip rooms field
    movl $garage_input, %edi
    movl $8, %ecx
    rep movsb

    movl (%esi), %eax  # mem with mem
    movl %eax, area_input

    movl 4(%esi), %eax  # mem with mem
    movl %eax, rent_input
    # [end] move strings from struct to inputs --------------------------------

    # print name
    pushl $name_str
    call printf
    addl $4, %esp
    pushl $name_input
    pushl $str_display
    call printf
    addl $8, %esp

    # print cell
    pushl $cell_str
    call printf
    addl $4, %esp
    pushl $cell_input
    pushl $str_display
    call printf
    addl $8, %esp

    # print property type
    pushl $property_str
    call printf
    addl $4, %esp
    pushl $property_input
    pushl $str_display
    call printf
    addl $8, %esp

    # print address
    pushl $address_str
    call printf
    addl $4, %esp
    pushl $address_input
    pushl $str_display
    call printf
    addl $8, %esp

    # print rooms
    pushl $rooms_str
    call printf
    addl $4, %esp
    pushl rooms_input
    pushl $num_display
    call printf
    addl $8, %esp

    # print garage
    pushl $garage_str
    call printf
    addl $4, %esp
    pushl $garage_input
    pushl $str_display
    call printf
    addl $8, %esp

    # print area
    pushl $area_str
    call printf
    addl $4, %esp
    pushl area_input
    pushl $num_display
    call printf
    addl $8, %esp

    # print rent
    pushl $rent_str
    call printf
    addl $4, %esp
    pushl rent_input
    pushl $num_display
    call printf
    addl $8, %esp

    popl %esi  # restore start of node

    # next node if exists
    cmpl $0, (%esi)
    je _end_print

    movl (%esi), %esi  # next node

    # print nl
    pushl $nl_str
    call printf
    addl $4, %esp

    jmp _loop1  # print again
    _end_print:

    ret
