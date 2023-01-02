describe('Rotas Post de Cliente', () => {

    let idCliente01;

    it('Criar cliente - Sucesso', () => {
        cy.request({
            method: 'POST', url: '/clientes', body: {
                "NOME": "Priscila G. Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('Cliente salvo com sucesso!');
            expect(Response.body[1].contato).to.equal("55229785634");
            expect(Response.body[1].nome).to.equal('Priscila G. Vieira');
            idCliente01 = Response.body[1].id;
        });
    });

    it('Criar cliente - Falha', () => {
        cy.request({
            method: 'POST', url: '/clientes', body: {
                "NOME": "Priscila G. Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        }).then((Response) => {
            expect(Response.status).to.equal(400);
            expect(Response.body.message).to.equal('Cliente possui cadastro');
        });
    });

    it('Buscar todos os clientes', () => {
        cy.request('/clientes').then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].contato).to.equal("55229785634");
            expect(Response.body[0].nome).to.equal('Priscila G. Vieira');
        });
    });

    it('Buscar clientes por ID', () => {
        cy.request(`/clientes/${idCliente01}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(idCliente01);
        });
    });

    it('Buscar clientes por Nº contato', () => {
        cy.request('/clientes/55229785634').then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.contato).to.equal('55229785634');
        });
    });

    it('Atualizar cliente por contato', () => {
        cy.request({
            method: 'PUT', url: '/clientes/55229785634', body: {
                "NOME": "Priscila Gomes Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Cliente atualizado com sucesso!');
            expect(Response.body[1].nome).to.equal('Priscila Gomes Vieira');
        });
    });

    it('Atualizar cliente por id', () => {
        cy.request({
            method: 'PUT', url: `/clientes/${idCliente01}`, body: {
                "ID": idCliente01,
                "NOME": "Priscila G. Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('Cliente atualizado com sucesso!');
            expect(Response.body[1].nome).to.equal('Priscila G. Vieira');
        });
    });

    it('Exclui cliente por ID', () => {
        cy.request({
            method: 'DELETE',
            url: `/clientes/${idCliente01}`,
            failOnStatusCode: false
        }).then(Res => {
            console.log(Res.body)
            expect(Res.status).to.equal(202);
            expect(Res.body.message).to.equal('Cliente excluído!');
        });
    });

    it('cliente não encontrado por contato', () => {
        cy.request({
            method: 'DELETE',
            url: '/clientes/55229785600',
            failOnStatusCode: false
        }).then(Res => {
            expect(Res.status).to.equal(404);
            expect(Res.body.message).to.equal('Cliente não encontrado');
        });
    });

    it('cliente não encontrado por ID', () => {
        cy.request({
            method: 'DELETE',
            url: '/clientes/2',
            failOnStatusCode: false
        }).then(Res => {
            expect(Res.status).to.equal(404);
            expect(Res.body.message).to.equal('Cliente não encontrado');
        });
    });
});