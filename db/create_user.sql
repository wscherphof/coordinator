drop user coord cascade;
create user coord identified by coord;
grant connect, resource, unlimited tablespace to coord;

drop user sched cascade;
create user sched identified by sched;
grant connect, resource, unlimited tablespace to sched;

drop user jms cascade;
create user jms identified by jms;
grant connect, resource, unlimited tablespace to jms;
exit
