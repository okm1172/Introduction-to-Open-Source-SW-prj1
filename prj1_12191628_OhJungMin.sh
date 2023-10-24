#!/bin/bash

init_print() {
	echo '--------------------------'
	echo "User Name : OhJungMin"
	echo 'Student Number: 12191628'
	echo "
[ MENU ]
1. Get the data of the movie identified by a specific 'movie id' from 'u.item'
2. Get the data of action genre movies from 'u.item'
3. Get the average 'rating' of the movie identified by
specific 'movie id' from 'u.data'
4. Delete the ‘IMDb URL’ from ‘u.item
5. Get the data about users from 'u.user'
6. Modify the format of 'release date' in 'u.item'
7. Get the data of movies rated by a specific 'user id' from 'u.data'
8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'
9. Exit"
echo '--------------------------'
}

func_1() {
	echo ""
	cat $1 | awk -v awk_id=$2 -F '|' '$1==awk_id {print $0}'	
	echo ""
}

func_2() {
	echo ""
	cat $1 | awk -F '|' '$7==1 {print $1" "$2}' | head -n 10
	echo ""
}

func_3() {
	id=$2
	echo ""
	echo -n "average rating of $id: "
	cat $1 | awk -v awk_id=$id -v sum=0 -v cnt=0 '$2==awk_id {sum+=$3;cnt+=1} END {print sum,cnt}' | awk '$2!=0 {printf("%.6g\n",$1/$2)}'
	echo ""	
}

func_4() {
	echo ""
	cat $1 | sed -E 's/http[^)]*\)/''/' | head -n 10
	echo ""
}

func_5() {
	echo ""
	#awk version.
	#cat $1 | awk -F '|' '$3=="M" {printf("user %d is %d years old male %s\n",$1,$2,$4)} $3=="F" {printf("user %d is %d years old female %s\n",$1,$2,$4)}'|head -n 10	
	
	#sed version
	cat $1 | sed -Ee 's/([0-9]+)[|]([0-9]+)[|][M][|]([a-zA-Z]+)[|](.*)/user \1 is \2 years old male \3/' -Ee 's/([0-9]+)[|]([0-9]+)[|][F][|]([a-zA-Z]+)[|](.*)/user \1 is \2 years old female \3/' | head -n 10
	echo ""
}

func_6() {
	#cat $1 | sed -E 's/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Jul/07/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/;' | sed -E 's/([0-9]+)-([0-9]+)-([0-9]+)/\3\2\1/' | tail -n 10
	cat $1 | sed -e 's/Jan/01/' -e's/Feb/02/' -e 's/Mar/03/' -e 's/Apr/04/' -e 's/May/05/' -e 's/Jun/06/' -e 's/Jul/07/' -e 's/Aug/08/' -e 's/Sep/09/' -e 's/Oct/10/' -e 's/Nov/11/' -e 's/Dec/12/' | sed -E 's/([0-9]+)-([0-9]+)-([0-9]+)/\3\2\1/' | tail -n 10
	echo ""
}

func_7() {
	echo ""
	movie=$(cat $2 | awk -v user_id=$3 '$1==user_id {print $2}'|sort -n)
	echo $movie | sed -E 's/ /|/g'
	cnt=0
	echo ""
	for movie_id in $movie
	do
		if [ $cnt -eq 10 ]; then
			break
		fi
		cnt=$((cnt+1))
		cat $1 | awk -F '|' -v id=$movie_id '$1==id {print $1"|"$2}'
	done
	echo ""
}

#$1는 u.data $2는 u.user
func_8() {
	echo ""
	age20_29=$(cat $2 | awk -v occupation="programmer" -F '|' '$2>=20 && $2<=29 && $4==occupation {printf("%d\n",$1)}')
	for who in $age20_29
	do
		cat $1 | awk -v person=$who '$1==person {print $2,$3}' >> final_data
	done
	for num in $(seq 1 1682)
	do
		cat final_data | awk -v n=$num -v cnt=0 -v sum=0 '$1==n {cnt+=1;sum+=$2} END {print n,sum,cnt}' >> real_final
	done
	$(rm final_data)
	cat real_final | awk '$3>0 {printf("%d %.6g\n",$1,$2/$3)}'
	$(rm real_final)
	echo ""
}

enter_choice() {
	while true
	do
		read -p "Enter your choice [ 1-9 ] " a
		if [ $a -eq 9 ];then
			echo "Bye!"
			break
		fi
		echo ""
		if [ $a -eq 1 ]; then
			read -p "Please enter 'move id'(1~1682) : " movie_id
			func_1 $1 $movie_id
		elif [ $a -eq 2 ]; then
			read -p "Do you want to get the data of 'action' genre movies from 'u.item'? (y/n) : " answer
			if [ "$answer" == "y" ]; then
				func_2 $1
			else
				echo ""
			fi
		elif [ $a -eq 3 ]; then
			read -p "Please enter the 'movie id'(1~1682) : " movie_id
			func_3 $2 $movie_id
		elif [ $a -eq 4 ]; then
			read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n) : " answer
			if [ "$answer" == "y" ]; then
				func_4 $1
			else
				echo ""
			fi
		elif [ $a -eq 5 ]; then
			read -p "Do you want to get the data about users from 'u.user'?(y/n) : " answer
			if [ "$answer" == "y" ]; then
				func_5 $3
			else
				echo ""
			fi
		elif [ $a -eq 6 ]; then
			read -p "Do you want to Modify the format of 'release data' in 'u.item'?(y/n) : " answer
			if [ "$answer" == "y" ]; then
				func_6 $1
			else
				echo ""
			fi
		elif [ $a -eq 7 ]; then
                        read -p "Please enter 'move id'(1~1682) : " user_id
                        func_7 $1 $2 $user_id
		elif [ $a -eq 8 ]; then
                        read -p "Do you want to Modify the format of 'release data' in 'u.item'?(y/n) : " answer
                        if [ "$answer" == "y" ]; then
                                func_8 $2 $3
                        else
                                echo ""
                        fi
                fi
	done
}

if [ $# -ne 3 ] || [ $1 != "u.item" ] || [ $2 != "u.data" ] || [ $3 != "u.user" ]; then
	echo "Please type like \"./file_name u.item u.data u.user\""
else
	init_print
	enter_choice $1 $2 $3
fi
