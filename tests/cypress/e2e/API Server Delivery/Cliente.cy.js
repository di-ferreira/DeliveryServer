describe('Rotas Post de Cliente', () => {

    it('Criar cliente - Sucesso', () => {
        cy.request({
            method: 'POST', url: '/cliente', body: {
                "NOME": "Priscila G. Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].Message).to.equal('Cliente salvo com sucesso!');
            expect(Response.body[1].contato).to.equal("55229785634");
            expect(Response.body[1].nome).to.equal('Priscila G. Vieira');
        });
    });

    it('Criar cliente - Falha', () => {
        cy.request({
            method: 'POST', url: '/cliente', body: {
                "NOME": "Priscila G. Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        }).then((Response) => {
            expect(Response.status).to.equal(400);
            expect(Response.body.ERROR).to.equal('Cliente possui cadastro');
        });
    });

});

describe('Rotas GET de Cliente', () => {

    it('Buscar todos os clientes', () => {
        cy.request('/cliente').then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].contato).to.equal("55229785634");
            expect(Response.body[0].nome).to.equal('Priscila G. Vieira');
        });
    });

    it('Buscar clientes por ID', () => {
        cy.request('/cliente/1').then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(1);
        });
    });

    it('Buscar clientes por Nº contato', () => {
        cy.request('/cliente/55229785634').then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.contato).to.equal('55229785634');
        });
    });
});

describe('Rotas UPDATE de Cliente', () => {
    it('Atualizar cliente por contato', () => {
        cy.request({
            method: 'PUT', url: '/cliente/55229785634', body: {
                "NOME": "Priscila Gomes Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].Message).to.equal('Cliente atualizado com sucesso!');
            expect(Response.body[1].nome).to.equal('Priscila Gomes Vieira');
        });
    });

    it('Atualizar cliente por id', () => {
        cy.request({
            method: 'PUT', url: '/cliente/1', body: {
                "ID": 1,
                "NOME": "Priscila G. Vieira",
                "CONTATO": "55229785634"
            }, failOnStatusCode: false
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].Message).to.equal('Cliente atualizado com sucesso!');
            expect(Response.body[1].nome).to.equal('Priscila G. Vieira');
        });
    });
});

describe('Rota DELETE de Cliente', () => {
    it('Exclui cliente por ID', () => {
        cy.request({
            method: 'DELETE',
            url: '/cliente/1',
            failOnStatusCode: false
        }).then(Res => {
            console.log(Res.body)
            expect(Res.status).to.equal(202);
            expect(Res.body.RESULT).to.equal('Cliente excluído!');
        });
    });

    it('cliente não encontrado por contato', () => {
        cy.request({
            method: 'DELETE',
            url: '/cliente/55229785600',
            failOnStatusCode: false
        }).then(Res => {
            expect(Res.status).to.equal(404);
            expect(Res.body.RESULT).to.equal('Cliente não encontrado');
        });
    });

    it('cliente não encontrado por ID', () => {
        cy.request({
            method: 'DELETE',
            url: '/cliente/2',
            failOnStatusCode: false
        }).then(Res => {
            expect(Res.status).to.equal(404);
            expect(Res.body.RESULT).to.equal('Cliente não encontrado');
        });
    });
});